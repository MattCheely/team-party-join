module Shared exposing
    ( Flags
    , Model
    , Msg(..)
    , UserStatus(..)
    , init
    , subscriptions
    , update
    , view
    )

import Api.Data exposing (Data(..))
import Api.Steam as Steam
import Api.Steam.OpenId as OpenId
import Api.Steam.SteamUser exposing (PlayerSummary)
import Bridge exposing (..)
import Gen.Route as Route
import Html exposing (..)
import Html.Attributes exposing (alt, class, href, rel, src, style)
import Html.Events exposing (onClick)
import Request exposing (Request)
import View exposing (View)



-- INIT


type alias Flags =
    ()


type alias Model =
    { user : UserStatus
    }


type UserStatus
    = LoggedOut
    | LoggedIn PlayerSummary
    | ProfileError Steam.Error


init : Request -> Flags -> ( Model, Cmd Msg )
init req _ =
    case OpenId.parseResponseUrl req.url of
        Just steamId ->
            ( { user = LoggedOut }
            , sendToBackend (GetUserInfo_Shared steamId)
            )

        Nothing ->
            ( { user = LoggedOut }, Cmd.none )



-- UPDATE


type Msg
    = ClickedSignOut
    | UserResult (Result Steam.Error PlayerSummary)


update : Request -> Msg -> Model -> ( Model, Cmd Msg )
update req msg model =
    case msg of
        UserResult (Ok playerSummary) ->
            ( { model | user = LoggedIn playerSummary }
            , Request.replaceRoute Route.Home_ req
            )

        UserResult (Err error) ->
            ( { model | user = ProfileError error }, Cmd.none )

        ClickedSignOut ->
            ( { model | user = LoggedOut }, sendToBackend SignedOut )



-- ( { model | user = Nothing }
-- , model.user |> Maybe.map (\user -> sendToBackend (SignedOut user)) |> Maybe.withDefault Cmd.none
-- )


subscriptions : Request -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none



-- VIEW


view :
    Request
    -> { page : View msg, toMsg : Msg -> msg }
    -> Model
    -> View msg
view req { page, toMsg } model =
    { title =
        if String.isEmpty page.title then
            "Steam Shared Games"

        else
            page.title
    , body =
        [ css
        , div [ class "dark-mode p-10 position-relative", style "min-height" "100vh" ]
            (Html.map toMsg (userHeader model.user) :: page.body)
        ]
    }


userHeader : UserStatus -> Html Msg
userHeader userStatus =
    case userStatus of
        LoggedIn user ->
            div
                [ class "d-flex align-items-center"
                , class "mb-10"
                ]
                [ div [ class "d-flex align-items-center" ]
                    [ img
                        [ class "flex-shrink-0 rounded-circle"
                        , alt ""
                        , src user.avatar
                        ]
                        []
                    ]
                , h1 [ class "ml-10 d-inline my-0" ] [ text user.personaName ]
                , button [ class "btn align-top ml-auto", onClick ClickedSignOut ]
                    [ text "Sign Out" ]
                ]

        _ ->
            text ""


css : Html msg
css =
    Html.node "link" [ rel "stylesheet", href "/style.css" ] []
