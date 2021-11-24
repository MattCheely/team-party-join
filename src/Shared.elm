module Shared exposing
    ( Flags
    , Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import Api.User exposing (User)
import Bridge exposing (..)
import Components.Footer
import Components.Navbar
import Html exposing (..)
import Html.Attributes exposing (class, href, rel, style)
import Request exposing (Request)
import Utils.Route
import View exposing (View)



-- INIT


type alias Flags =
    ()


type alias Model =
    { user : Maybe User
    }


init : Request -> Flags -> ( Model, Cmd Msg )
init _ json =
    ( Model Nothing
    , Cmd.none
    )



-- UPDATE


type Msg
    = ClickedSignOut
    | SignedInUser User


update : Request -> Msg -> Model -> ( Model, Cmd Msg )
update _ msg model =
    case msg of
        SignedInUser user ->
            ( { model | user = Just user }
            , Cmd.none
            )

        ClickedSignOut ->
            ( { model | user = Nothing }
            , model.user |> Maybe.map (\user -> sendToBackend (SignedOut user)) |> Maybe.withDefault Cmd.none
            )


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
            "Conduit"

        else
            page.title ++ " | Conduit"
    , body =
        css
            ++ [ div [ class "dark-mode p-10", style "min-height" "100%" ]
                    [ div [ class "page" ] page.body
                    ]
               ]
    }


css =
    -- Import Ionicon icons & Google Fonts our Bootstrap theme relies on
    [ Html.node "link" [ rel "stylesheet", href "//cdn.jsdelivr.net/npm/halfmoon@1.1.1/css/halfmoon-variables.min.css" ] []
    ]
