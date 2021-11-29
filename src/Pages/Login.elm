module Pages.Login exposing (Model, Msg(..), page)

import Api.Steam.OpenId as OpenId
import Bridge exposing (..)
import Browser.Navigation as Nav
import Effect exposing (Effect)
import Gen.Route as Route
import Html exposing (Html, button, div, img, text)
import Html.Attributes exposing (alt, class, src)
import Html.Events exposing (onClick)
import Page
import Request exposing (Request)
import Shared exposing (UserStatus(..))
import Url exposing (Url)
import Utils.Url as Url
import View exposing (View)


page : Shared.Model -> Request -> Page.With Model Msg
page shared req =
    Page.advanced
        { init = init shared req
        , update = update req
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


type alias Model =
    { loginRedirectUrl : Url
    , showProfileError : Bool
    }


init : Shared.Model -> Request -> ( Model, Effect Msg )
init shared req =
    let
        domain =
            Url.domain req.url

        loginRedirectUrl =
            { domain | path = "/" }

        model =
            { loginRedirectUrl = loginRedirectUrl
            , showProfileError = False
            }
    in
    case shared.user of
        LoggedIn _ ->
            ( model
            , Request.pushRoute Route.Home_ req
                |> Effect.fromCmd
            )

        LoggedOut ->
            ( model, Effect.none )

        ProfileError _ ->
            ( { model | showProfileError = True }, Effect.none )



-- UPDATE


type Msg
    = SteamSignIn


update : Request -> Msg -> Model -> ( Model, Effect Msg )
update req msg model =
    case msg of
        SteamSignIn ->
            ( model
            , Nav.load (OpenId.getLoginUrl model.loginRedirectUrl)
                |> Effect.fromCmd
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Sign in"
    , body =
        [ if model.showProfileError then
            profileErrorView

          else
            text ""
        , signInView
        ]
    }


signInView : Html Msg
signInView =
    div [ class "h-full d-flex justify-content-center algin-items-center" ]
        [ button [ class "btn-image", onClick SteamSignIn ]
            [ img [ src "/steam-sign-in.png", alt "Sign in with Steam" ] []
            ]
        ]


profileErrorView : Html Msg
profileErrorView =
    div []
        [ text "We were unable to fetch your profile information. Your profile must be public to use this app."
        ]
