module Pages.Home_ exposing (Model, Msg(..), page)

import Api.Data exposing (Data(..))
import Api.Steam as Steam
import Api.Steam.PlayerService exposing (GameList, GameSummary)
import Bridge exposing (..)
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (value)
import Html.Events exposing (onClick, onInput)
import Page
import Request exposing (Request)
import Shared
import View exposing (View)


page : Shared.Model -> Request -> Page.With Model Msg
page _ _ =
    Page.protected.element
        (\user ->
            { init = init
            , update = update
            , subscriptions = subscriptions
            , view = view
            }
        )



-- INIT


type alias Model =
    { steamIds : List String
    , gamesByUser : Dict String (Data Steam.Error GameList)
    }


init : ( Model, Cmd Msg )
init =
    ( { steamIds = []
      , gamesByUser = Dict.empty
      }
    , Cmd.none
    )


updateIdAt : Int -> String -> List String -> List String
updateIdAt updateAt newId steamIds =
    steamIds
        |> List.indexedMap
            (\idx currentId ->
                if idx == updateAt then
                    newId

                else
                    currentId
            )


type GameOptions
    = Working
    | Finished
        { games : Dict Int GameSummary
        , errorIds : List String
        }


buildGameOptions : Dict String (Data Steam.Error GameList) -> GameOptions
buildGameOptions gamesByUser =
    buildGameOptionsRecur (Dict.toList gamesByUser)
        { games = Nothing, errorIds = [] }


buildGameOptionsRecur :
    List ( String, Data Steam.Error GameList )
    -> { games : Maybe (Dict Int GameSummary), errorIds : List String }
    -> GameOptions
buildGameOptionsRecur uncheckedRequests optionsSoFar =
    case uncheckedRequests of
        [] ->
            -- We're Done
            Finished
                { games = Maybe.withDefault Dict.empty optionsSoFar.games
                , errorIds = optionsSoFar.errorIds
                }

        ( nextId, nextReq ) :: rest ->
            case nextReq of
                Loading ->
                    Working

                -- This shouldn't happen, but let's call it Working
                NotAsked ->
                    Working

                Failure _ ->
                    { optionsSoFar | errorIds = nextId :: optionsSoFar.errorIds }
                        |> buildGameOptionsRecur rest

                Success gameList ->
                    let
                        sharedGames =
                            case optionsSoFar.games of
                                Nothing ->
                                    Just (gameListAsDict gameList)

                                Just gamesSoFar ->
                                    Just (intersectGames gameList gamesSoFar)
                    in
                    { optionsSoFar | games = sharedGames }
                        |> buildGameOptionsRecur rest


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
    = UpdatedId Int String
    | NewSteamId String
    | LookupGames
    | GotGames String (Data Steam.Error GameList)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewSteamId steamId ->
            ( { model | steamIds = model.steamIds ++ [ steamId ] }, Cmd.none )

        UpdatedId idx steamId ->
            ( { model | steamIds = updateIdAt idx steamId model.steamIds }
            , Cmd.none
            )

        LookupGames ->
            ( { model
                | gamesByUser =
                    model.steamIds
                        |> List.map (\id -> ( id, Loading ))
                        |> Dict.fromList
              }
            , Cmd.batch (List.map lookupGamesForUser model.steamIds)
            )

        GotGames steamId response ->
            ( { model
                | gamesByUser =
                    model.gamesByUser
                        |> Dict.insert steamId response
              }
            , Cmd.none
            )


lookupGamesForUser : String -> Cmd Msg
lookupGamesForUser steamId =
    sendToBackend (LookupGames_Home { steamId = steamId })


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Home"
    , body =
        if Dict.isEmpty model.gamesByUser then
            [ enterIdsView model.steamIds ]

        else
            [ multiplayerOptionsView model.gamesByUser ]
    }


multiplayerOptionsView : Dict String (Data Steam.Error GameList) -> Html Msg
multiplayerOptionsView gamesByUser =
    let
        options =
            buildGameOptions gamesByUser
    in
    case options of
        Working ->
            text "Loading..."

        Finished status ->
            div []
                [ userSummariesView gamesByUser
                , h3 [] [ text (String.fromInt (Dict.size status.games)), text " shared games" ]
                , div [] (List.map gameSummaryView (Dict.values status.games))
                ]


userSummariesView : Dict String (Data Steam.Error GameList) -> Html Msg
userSummariesView userStatuses =
    div []
        (List.map userSummaryView (Dict.toList userStatuses))


userSummaryView : ( String, Data Steam.Error GameList ) -> Html Msg
userSummaryView ( steamId, gameResponse ) =
    case gameResponse of
        NotAsked ->
            div [] [ text steamId, text ": Data not requested" ]

        Loading ->
            div [] [ text steamId, text ": Loading..." ]

        Failure _ ->
            div [] [ text steamId, text ": Error fetching game list" ]

        Success gameList ->
            div [] [ text steamId, text ": ", text (String.fromInt gameList.gameCount), text " games" ]


enterIdsView : List String -> Html Msg
enterIdsView steamIds =
    div []
        [ div []
            (List.indexedMap idInputView steamIds
                ++ [ div []
                        [ input [ onInput NewSteamId, value "" ] []
                        ]
                   ]
            )
        , button [ onClick LookupGames ] [ text "Find Multiplayer Options" ]
        ]


idInputView : Int -> String -> Html Msg
idInputView idx steamId =
    div []
        [ input [ onInput (UpdatedId idx), value steamId ] []
        ]


gameSummaryView : GameSummary -> Html Msg
gameSummaryView game =
    div []
        [ span [] [ text game.name ] ]
