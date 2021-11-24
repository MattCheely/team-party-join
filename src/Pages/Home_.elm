module Pages.Home_ exposing (Model, Msg(..), page)

import Api.Data exposing (Data(..))
import Api.Steam as Steam
import Api.Steam.PlayerService exposing (GameList, GameSummary)
import Bridge exposing (..)
import Html exposing (..)
import Html.Attributes exposing (value)
import Html.Events as Events exposing (onClick, onInput)
import Page
import Request exposing (Request)
import Shared
import View exposing (View)


page : Shared.Model -> Request -> Page.With Model Msg
page shared _ =
    Page.element
        { init = init shared
        , update = update shared
        , subscriptions = subscriptions
        , view = view shared
        }



-- INIT


type alias Model =
    { steamId : String
    , gameList : Data Steam.Error GameList
    }


init : Shared.Model -> ( Model, Cmd Msg )
init shared =
    let
        model : Model
        model =
            { steamId = "76561197982907529"
            , gameList = NotAsked
            }
    in
    ( model, Cmd.none )



-- UPDATE


type Msg
    = UpdatedSteamId String
    | LookupGames
    | GotGames (Data Steam.Error GameList)


update : Shared.Model -> Msg -> Model -> ( Model, Cmd Msg )
update shared msg model =
    case msg of
        UpdatedSteamId steamId ->
            ( { model | steamId = steamId }, Cmd.none )

        LookupGames ->
            ( { model | gameList = Loading }
            , LookupGames_Home { steamId = model.steamId }
                |> sendToBackend
            )

        GotGames response ->
            ( { model | gameList = response }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Shared.Model -> Model -> View Msg
view shared model =
    { title = ""
    , body =
        case model.gameList of
            NotAsked ->
                [ input [ value model.steamId, onInput UpdatedSteamId ] []
                , button [ onClick LookupGames ] [ text "Lookup Games" ]
                ]

            Loading ->
                [ text "Loading..." ]

            Success games ->
                [ gamesView games ]

            Failure err ->
                [ text "Failed to fetch games" ]
    }


gamesView : GameList -> Html Msg
gamesView { games } =
    div []
        (List.map gameSummaryView games)


gameSummaryView : GameSummary -> Html Msg
gameSummaryView game =
    div []
        [ span [] [ text game.name ] ]
