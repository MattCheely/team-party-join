module Pages.SharedGames.SteamIds_ exposing (Model, Msg(..), page)

import Api.Data as Data exposing (Data(..))
import Api.Steam as Steam
import Api.Steam.Extra exposing (AppMetaData)
import Api.Steam.PlayerService exposing (GameList, GameSummary)
import Api.Steam.SteamUser exposing (PlayerSummary)
import Bridge exposing (..)
import Dict exposing (Dict)
import Gen.Params.SharedGames.SteamIds_ exposing (Params)
import Html exposing (Attribute, Html, a, div, h3, img, input, label, span, text)
import Html.Attributes exposing (alt, attribute, checked, class, for, href, id, src, target, title, type_)
import Html.Events exposing (onCheck, onClick)
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
    , includes : Includes
    , games : Dict Int GameData
    }


asIncludesIn : Model -> Includes -> Model
asIncludesIn model includes =
    { model | includes = includes }


type alias Includes =
    { coOp : Bool
    , pvp : Bool
    , multiplayer : Bool
    , remotePlayTogether : Bool
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
      , includes = Includes True True True False
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


multiplayerNow : Model -> GameData -> Bool
multiplayerNow model game =
    let
        includes =
            model.includes

        allOwn =
            ownedByAll model game
    in
    Set.empty
        |> Set.union (matchCategories (allOwn && includes.pvp) game.summary pvpCategories)
        |> Set.union (matchCategories (allOwn && includes.coOp) game.summary coOpCategories)
        |> Set.union (matchCategories (allOwn && includes.multiplayer) game.summary multiplayerCategories)
        |> Set.union (matchCategories includes.remotePlayTogether game.summary remotePlayCategories)
        |> (not << Set.isEmpty)


matchedCategories : Includes -> GameSummary -> Set String
matchedCategories includes game =
    Set.empty
        |> Set.union (matchCategories includes.pvp game pvpCategories)
        |> Set.union (matchCategories includes.coOp game coOpCategories)
        |> Set.union (matchCategories includes.multiplayer game multiplayerCategories)
        |> Set.union (matchCategories includes.remotePlayTogether game remotePlayCategories)


multiplayerCategories =
    Set.fromList [ "Multi-player" ]


pvpCategories =
    Set.fromList [ "Online PvP", "Online-PvP" ]


coOpCategories =
    Set.fromList [ "Online Co-op" ]


remotePlayCategories =
    Set.fromList [ "Remote Play Together" ]


matchCategories : Bool -> GameSummary -> Set String -> Set String
matchCategories doMatch game categories =
    if not doMatch then
        Set.empty

    else
        Set.intersect game.categories categories



-- UPDATE


type Msg
    = GotGames String (Data Steam.Error GameList)
    | GotPlayerSummaries (Data Steam.Error (List PlayerSummary))
    | SetCoOp Bool
    | SetPvP Bool
    | SetRemotePlay Bool
    | SetMultiplayer Bool


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

        SetCoOp coOp ->
            let
                includes =
                    Debug.log "INCLUDES PRE TOGGLE" model.includes
            in
            ( { includes | coOp = coOp } |> asIncludesIn model, Cmd.none )

        SetPvP pvp ->
            let
                includes =
                    model.includes
            in
            ( { includes | pvp = pvp } |> asIncludesIn model, Cmd.none )

        SetRemotePlay remotePlay ->
            let
                includes =
                    model.includes
            in
            ( { includes | remotePlayTogether = remotePlay } |> asIncludesIn model, Cmd.none )

        SetMultiplayer multiplayer ->
            let
                includes =
                    model.includes
            in
            ( { includes | multiplayer = multiplayer } |> asIncludesIn model, Cmd.none )


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
    in
    div []
        [ playerSummariesView (Dict.values playerData)
        , filterOptionsView (Debug.log "Includes" model.includes)
        , gameOptionsView model
        ]


filterOptionsView : Includes -> Html Msg
filterOptionsView includes =
    div [ class "d-flex mt-10" ]
        [ checkbox [ onCheck SetCoOp, class "mr-20" ] "Co-Op" includes.coOp
        , checkbox [ onCheck SetPvP, class "mr-20" ] "Pvp" includes.pvp
        , checkbox
            [ onCheck SetMultiplayer
            , class "mr-20"
            , attribute "data-toggle" "tooltip"
            , attribute "data-title" "Some online games are just flagged as 'Multiplayer'"
            ]
            "\"Multiplayer\""
            includes.multiplayer
        , checkbox
            [ onCheck SetRemotePlay
            , attribute "data-toggle" "tooltip"
            , attribute "data-title" "Matches if anyone in the party owns it"
            ]
            "Remote Play Together"
            includes.remotePlayTogether
        ]


checkbox : List (Attribute msg) -> String -> Bool -> Html msg
checkbox attrs labelStr isChecked =
    div (class "custom-checkbox" :: attrs)
        [ input [ type_ "checkbox", id labelStr, checked isChecked ] []
        , label [ for labelStr ] [ text labelStr ]
        ]


gameOptionsView : Model -> Html Msg
gameOptionsView model =
    let
        matchedGames =
            List.filter (multiplayerNow model) (Dict.values model.games)
    in
    div []
        (if gamesLoaded model then
            [ h3 []
                [ span []
                    [ text (String.fromInt (List.length matchedGames)), text " Options" ]
                ]
            , div []
                (matchedGames
                    |> List.map .summary
                    |> List.sortBy .name
                    |> List.map (gameSummaryView model.includes)
                )
            ]

         else
            [ h3 [] [ text "Fetching Game Details..." ] ]
        )


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


gameSummaryView : Includes -> GameSummary -> Html Msg
gameSummaryView includes game =
    div [ class "d-inline-block m-5" ]
        [ a
            [ href ("https://store.steampowered.com/app/" ++ String.fromInt game.appId)
            , target "_blank"
            , attribute "data-toggle" "tooltip"
            , attribute "data-title" (matchedCategories includes game |> Set.toList |> String.join "\n")
            , class "d-inline-block"
            ]
            [ img
                [ src game.logoUrl
                , alt game.name

                -- , title (matchedCategories includes game |> Set.toList |> String.join " , ")
                ]
                []
            ]
        ]
