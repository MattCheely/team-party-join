module Pages.SharedGames.SteamIds_ exposing (Model, Msg(..), page)

import Api.Data as Data exposing (Data(..))
import Api.Steam as Steam
import Api.Steam.Extra exposing (AppMetaData)
import Api.Steam.PlayerService exposing (GameList, GameSummary)
import Api.Steam.SteamUser exposing (PlayerSummary)
import Bridge exposing (..)
import Dict exposing (Dict)
import Gen.Params.SharedGames.SteamIds_ exposing (Params)
import Html exposing (Html, a, div, h3, img, span, text)
import Html.Attributes exposing (alt, attribute, class, href, src, target, title)
import Page
import Request
import Set exposing (Set)
import Shared
import Ui
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared req =
    Page.element
        { init = init req.params
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias Model =
    { players : Dict String PlayerData
    , games : Dict Int GameData
    }


type alias GameData =
    { summary : GameSummary
    , ownedBy : Set String
    }


type alias PlayerData =
    { profile : Data Steam.Error PlayerSummary
    , gameCount : Data Steam.Error Int
    }


init : Params -> ( Model, Cmd Msg )
init params =
    let
        steamIds =
            String.split "," params.steamIds

        initialPlayerData =
            { profile = Loading, gameCount = Loading }
    in
    ( { players =
            steamIds
                |> List.map (\id -> ( id, initialPlayerData ))
                |> Dict.fromList
      , games = Dict.empty
      }
    , sendToBackend (GetPlayerSummaries_SharedGames steamIds)
        :: List.map lookupGamesForUser steamIds
        |> Cmd.batch
    )


gamesLoaded : Model -> Bool
gamesLoaded model =
    Dict.values model.players
        |> List.map .gameCount
        |> List.all Data.finished


lookupGamesForUser : String -> Cmd Msg
lookupGamesForUser steamId =
    sendToBackend (LookupGames_SharedGames steamId)


ownedByAll : Model -> GameData -> Bool
ownedByAll model game =
    Set.size game.ownedBy == Dict.size model.players


onlinePvp : GameData -> Bool
onlinePvp game =
    Set.member "Online PvP" game.summary.categories
        || Set.member "Online-PvP" game.summary.categories


onlineCoOp : GameData -> Bool
onlineCoOp game =
    Set.member "Online Co-op" game.summary.categories


remotePlayTogether : GameData -> Bool
remotePlayTogether game =
    Set.member "Remote Play Together" game.summary.categories


multiplayerNow : Model -> GameData -> Bool
multiplayerNow model game =
    (ownedByAll model game && (onlinePvp game || onlineCoOp game))
        || remotePlayTogether game



-- UPDATE


type Msg
    = GotGames String (Data Steam.Error GameList)
    | GotPlayerSummaries (Data Steam.Error (List PlayerSummary))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotPlayerSummaries playerResponses ->
            ( { model
                | players =
                    setPlayerResponses model.players playerResponses
              }
            , Cmd.none
            )

        GotGames steamId response ->
            ( { model
                | players =
                    model.players
                        |> Dict.update steamId (setGameCount response)
                , games =
                    model.games |> addGamesFor steamId response
              }
            , Cmd.none
            )


addGamesFor : String -> Data Steam.Error GameList -> Dict Int GameData -> Dict Int GameData
addGamesFor steamId gameResponse games =
    case gameResponse of
        Success gameList ->
            List.foldl (addGameFor steamId) games gameList.games

        _ ->
            games


addGameFor : String -> GameSummary -> Dict Int GameData -> Dict Int GameData
addGameFor steamId summary gameDatas =
    gameDatas
        |> Dict.update summary.appId
            (\gameData ->
                Maybe.map (\data -> { data | ownedBy = Set.insert steamId data.ownedBy }) gameData
                    |> Maybe.withDefault
                        { summary = summary
                        , ownedBy = Set.fromList [ steamId ]
                        }
                    |> Just
            )


setGameCount : Data Steam.Error GameList -> Maybe PlayerData -> Maybe PlayerData
setGameCount response playerData =
    playerData
        |> Maybe.map
            (\data ->
                { data | gameCount = Data.map .gameCount response }
            )


setPlayerResponse : PlayerSummary -> Maybe PlayerData -> Maybe PlayerData
setPlayerResponse summary playerData =
    playerData
        |> Maybe.map
            (\data ->
                { data | profile = Success summary }
            )


setPlayerResponses : Dict String PlayerData -> Data Steam.Error (List PlayerSummary) -> Dict String PlayerData
setPlayerResponses playerData response =
    case response of
        Failure err ->
            Dict.map
                (\_ player ->
                    { player | profile = Failure err }
                )
                playerData

        Success players ->
            players
                |> List.foldl
                    (\summary data ->
                        Dict.update summary.steamId (setPlayerResponse summary) data
                    )
                    playerData

        NotAsked ->
            playerData

        Loading ->
            playerData



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Multiplayer Game Options"
    , body =
        [ multiplayerOptionsView model ]
    }


multiplayerOptionsView : Model -> Html Msg
multiplayerOptionsView model =
    let
        playerData =
            model.players

        matchedGames =
            List.filter (multiplayerNow model) (Dict.values model.games)
    in
    div []
        [ playerSummariesView (Dict.values playerData)
        , div []
            (if gamesLoaded model then
                [ h3 []
                    [ span
                        [ attribute "data-toggle" "tooltip"
                        , attribute "data-title" "Owned by all with online multiplayer, or owned by anyone with remote play together"
                        ]
                        [ text (String.fromInt (List.length matchedGames)), text " Multiplayer Options" ]
                    ]
                , div []
                    (matchedGames
                        |> List.map .summary
                        |> List.sortBy .name
                        |> List.map gameSummaryView
                    )
                ]

             else
                [ h3 [] [ text "Fetching Game Details..." ] ]
            )
        ]


playerSummariesView : List PlayerData -> Html Msg
playerSummariesView playerData =
    div []
        (List.map playerSummaryView playerData)


playerSummaryView : PlayerData -> Html Msg
playerSummaryView playerData =
    let
        ( name, avatar ) =
            case playerData.profile of
                NotAsked ->
                    ( "Loading", "" )

                Loading ->
                    ( "Loading", "" )

                Failure _ ->
                    ( "Unknown", "" )

                Success profile ->
                    ( profile.personaName, profile.avatarMedium )

        note =
            case playerData.gameCount of
                NotAsked ->
                    text "..."

                Loading ->
                    text "..."

                Failure _ ->
                    span
                        [ class "alert alert-danger py-0 px-5"
                        , title "User's profile must be public to get games"
                        ]
                        [ text "Error" ]

                Success gameCount ->
                    text (String.fromInt gameCount ++ " games")
    in
    Ui.playerCard [ class "mr-10 mb-10" ]
        { name = name, avatar = avatar, note = note }


gameSummaryView : GameSummary -> Html Msg
gameSummaryView game =
    div [ class "d-inline-block m-5" ]
        [ a
            [ href ("https://store.steampowered.com/app/" ++ String.fromInt game.appId)
            , target "_blank"
            ]
            [ img
                [ src game.logoUrl
                , title game.name
                ]
                []
            ]
        ]
