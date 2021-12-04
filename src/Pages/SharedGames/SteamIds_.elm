module Pages.SharedGames.SteamIds_ exposing (Model, Msg(..), page)

import Api.Data exposing (Data(..))
import Api.Steam as Steam
import Api.Steam.PlayerService exposing (GameList, GameSummary)
import Api.Steam.SteamUser exposing (PlayerSummary)
import Bridge exposing (..)
import Dict exposing (Dict)
import Gen.Params.SharedGames.SteamIds_ exposing (Params)
import Html exposing (Html, a, div, h3, img, text)
import Html.Attributes exposing (alt, class, href, src, target)
import Page
import Request
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
    }


type alias PlayerData =
    { profile : Data Steam.Error PlayerSummary
    , games : Data Steam.Error GameList
    }


init : Params -> ( Model, Cmd Msg )
init params =
    let
        steamIds =
            String.split "," params.steamIds

        initialPlayerData =
            { profile = Loading, games = Loading }
    in
    ( { players =
            steamIds
                |> List.map (\id -> ( id, initialPlayerData ))
                |> Dict.fromList
      }
    , sendToBackend (GetPlayerSummaries_SharedGames steamIds)
        :: List.map lookupGamesForUser steamIds
        |> Cmd.batch
    )


lookupGamesForUser : String -> Cmd Msg
lookupGamesForUser steamId =
    sendToBackend (LookupGames_SharedGames steamId)


type GameOptions
    = Working
    | Finished (Dict Int GameSummary)


buildGameOptions : Dict String PlayerData -> GameOptions
buildGameOptions playerData =
    buildGameOptionsRecur (Dict.values playerData |> List.map .games)
        Nothing


buildGameOptionsRecur :
    List (Data Steam.Error GameList)
    -> Maybe (Dict Int GameSummary)
    -> GameOptions
buildGameOptionsRecur uncheckedRequests optionsSoFar =
    case uncheckedRequests of
        [] ->
            -- We're Done
            Finished (optionsSoFar |> Maybe.withDefault Dict.empty)

        nextReq :: rest ->
            case nextReq of
                Loading ->
                    Working

                -- This shouldn't happen, but let's call it Working
                NotAsked ->
                    Working

                Failure _ ->
                    buildGameOptionsRecur rest optionsSoFar

                Success gameList ->
                    let
                        sharedGames =
                            case optionsSoFar of
                                Nothing ->
                                    Just (gameListAsDict gameList)

                                Just gamesSoFar ->
                                    Just (intersectGames gameList gamesSoFar)
                    in
                    buildGameOptionsRecur rest sharedGames


gameListAsDict : GameList -> Dict Int GameSummary
gameListAsDict gameList =
    gameList.games
        |> List.map (\summary -> ( summary.appId, summary ))
        |> Dict.fromList


intersectGames : GameList -> Dict Int GameSummary -> Dict Int GameSummary
intersectGames gameList gameDict =
    gameListAsDict gameList
        |> Dict.intersect gameDict



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
                        |> Dict.update steamId (setGamesResponse response)
              }
            , Cmd.none
            )


setGamesResponse : Data Steam.Error GameList -> Maybe PlayerData -> Maybe PlayerData
setGamesResponse response playerData =
    playerData
        |> Maybe.map
            (\data ->
                { data | games = response }
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
        [ multiplayerOptionsView model.players ]
    }


multiplayerOptionsView : Dict String PlayerData -> Html Msg
multiplayerOptionsView playerData =
    let
        options =
            buildGameOptions playerData
    in
    case options of
        Working ->
            text "Loading..."

        Finished status ->
            div []
                [ playerSummariesView (Dict.values playerData)
                , h3 [] [ text (String.fromInt (Dict.size status)), text " Multiplayer Options" ]
                , div []
                    (Dict.values status
                        |> List.sortBy .name
                        |> List.map gameSummaryView
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
            case playerData.games of
                NotAsked ->
                    "..."

                Loading ->
                    "..."

                Failure _ ->
                    "Error"

                Success gameList ->
                    String.fromInt gameList.gameCount ++ " games"
    in
    Ui.playerCard [ class "mr-10" ]
        { name = name, avatar = avatar, note = note }


gameSummaryView : GameSummary -> Html Msg
gameSummaryView game =
    div [ class "d-inline-block m-5" ]
        [ a
            [ href ("https://store.steampowered.com/app/" ++ String.fromInt game.appId)
            , target "_blank"
            ]
            [ img [ src game.logoUrl, alt game.name ] [] ]
        ]
