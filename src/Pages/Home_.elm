module Pages.Home_ exposing (Model, Msg(..), page)

import Api.Data exposing (Data(..))
import Api.Steam as Steam exposing (SteamId)
import Api.Steam.SteamUser exposing (PlayerSummary)
import Auth exposing (User)
import Bridge exposing (..)
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Gen.Route as Route
import Html exposing (..)
import Html.Attributes exposing (alt, class, classList, src)
import Html.Events exposing (onClick)
import Page
import Request exposing (Request)
import Set exposing (Set)
import Shared
import Ui
import Utils.Route exposing (navigate)
import View exposing (View)


page : Shared.Model -> Request -> Page.With Model Msg
page _ req =
    Page.protected.element
        (\user ->
            { init = init user
            , update = update req.key user
            , subscriptions = subscriptions
            , view = view
            }
        )



-- INIT


type alias Model =
    { friends : Data Steam.Error (List PlayerSummary)
    , selectedFriends : Set SteamId
    }


init : User -> ( Model, Cmd Msg )
init user =
    ( { friends = Loading
      , selectedFriends = Set.empty
      }
    , sendToBackend (GetFriendsList_Home user.steamId)
    )



-- UPDATE


type Msg
    = GotFriends (Data Steam.Error (List PlayerSummary))
    | ToggleSelected SteamId
    | LookupGames


update : Nav.Key -> User -> Msg -> Model -> ( Model, Cmd Msg )
update key user msg model =
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
                idsParam =
                    model.selectedFriends
                        |> Set.toList
                        |> (::) user.steamId
                        |> String.join ","
            in
            ( model
            , navigate key (Route.SharedGames__SteamIds_ { steamIds = idsParam })
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Select Friends"
    , body =
        [ friendsSelectionView model.friends model.selectedFriends ]
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
                [ div []
                    [ h2 [] [ text "Select Your Team" ] ]
                , div [ class "row row-eq-spacing px-0 my-20" ]
                    (List.sortBy (.personaName >> String.toLower) friends
                        |> List.map (friendSelectionView selectedFriends)
                    )
                , div []
                    [ button [ class "btn btn-primary", onClick LookupGames ]
                        [ text "Get Shared Games" ]
                    ]
                ]


friendSelectionView : Set SteamId -> PlayerSummary -> Html Msg
friendSelectionView selectedFriends friend =
    let
        selected =
            Set.member friend.steamId selectedFriends
    in
    div [ class "col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2" ]
        [ button
            [ class "btn-image w-full mb-10 rounded"
            , classList [ ( "bg-primary", selected ) ]
            , onClick (ToggleSelected friend.steamId)
            ]
            [ Ui.playerCard [ class "w-full" ]
                { name = friend.personaName, avatar = friend.avatarMedium, note = text "" }
            ]
        ]
