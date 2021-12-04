module Pages.Home_ exposing (Model, Msg(..), page)

import Api.Data exposing (Data(..))
import Api.Steam as Steam exposing (SteamId)
import Api.Steam.PlayerService exposing (GameList, GameSummary)
import Api.Steam.SteamUser exposing (PlayerSummary)
import Auth exposing (User)
import Bridge exposing (..)
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (alt, class, classList, src, value)
import Html.Events exposing (onClick, onInput)
import Page
import Request exposing (Request)
import Set exposing (Set)
import Shared
import View exposing (View)


page : Shared.Model -> Request -> Page.With Model Msg
page _ _ =
    Page.protected.element
        (\user ->
            { init = init user
            , update = update
            , subscriptions = subscriptions
            , view = view
            }
        )



-- INIT


type alias Model =
    { friends : Data Steam.Error (List PlayerSummary)
    , selectedFriends : Set SteamId
    , gamesByUser : Dict String (Data Steam.Error GameList)
    }


init : User -> ( Model, Cmd Msg )
init user =
    ( { friends = Loading
      , selectedFriends = Set.empty
      , gamesByUser = Dict.empty
      }
    , sendToBackend (GetFriendsList_Home user.steamId)
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
    = GotFriends (Data Steam.Error (List PlayerSummary))
    | ToggleSelected SteamId
    | LookupGames
    | GotGames String (Data Steam.Error GameList)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotFriends friends ->
            ( { model | friends = friends }, Cmd.none )

        ToggleSelected steamId ->
            let
                newSelection =
                    if Set.member steamId model.selectedFriends then
                        Set.remove steamId model.selectedFriends

                    else
                        Set.insert steamId model.selectedFriends
            in
            ( { model | selectedFriends = newSelection }, Cmd.none )

        LookupGames ->
            let
                steamIds =
                    Set.toList model.selectedFriends
            in
            ( { model
                | gamesByUser =
                    steamIds
                        |> List.map (\id -> ( id, Loading ))
                        |> Dict.fromList
              }
            , Cmd.batch (List.map lookupGamesForUser steamIds)
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
    sendToBackend (LookupGames_Home steamId)


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Home"
    , body =
        if Dict.isEmpty model.gamesByUser then
            [ friendsSelectionView model.friends model.selectedFriends ]

        else
            [ multiplayerOptionsView model.gamesByUser ]
    }


friendsSelectionView : Data Steam.Error (List PlayerSummary) -> Set SteamId -> Html Msg
friendsSelectionView friendStatus selectedFriends =
    case friendStatus of
        NotAsked ->
            text "Loading..."

        Loading ->
            text "Loading..."

        Failure _ ->
            text "Unable to fetch friend list. Please make sure that data is public."

        Success friends ->
            div []
                [ div [ class "row row-eq-spacing" ]
                    (List.sortBy (.personaName >> String.toLower) friends
                        |> List.map (friendSelectionView selectedFriends)
                    )
                , button [ class "btn btn-primary", onClick LookupGames ]
                    [ text "Get Shared Games" ]
                ]


friendSelectionView : Set SteamId -> PlayerSummary -> Html Msg
friendSelectionView selectedFriends friend =
    let
        selected =
            Set.member friend.steamId selectedFriends
    in
    div [ class "col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2" ]
        [ button
            [ class "btn-image border rounded p-10"
            , classList [ ( "bg-primary", selected ) ]
            , onClick (ToggleSelected friend.steamId)
            , class "w-full mb-20"
            , class "text-left text-truncate"
            ]
            [ div
                [ class "d-inline-flex align-items-center"
                , classList [ ( "fade-50", not selected ) ]
                ]
                [ img
                    [ class "rounded-circle w-25"
                    , src friend.avatar
                    , alt ""
                    ]
                    []
                , div [ class "ml-10" ]
                    [ text friend.personaName ]
                ]
            ]
        ]


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
                , div []
                    (Dict.values status.games
                        |> List.sortBy .name
                        |> List.map gameSummaryView
                    )
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


gameSummaryView : GameSummary -> Html Msg
gameSummaryView game =
    div []
        [ span [] [ text game.name ] ]
