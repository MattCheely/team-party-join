module Evergreen.V1.Pages.Login exposing (..)

import Url


type alias Model =
    { loginRedirectUrl : Url.Url
    , showProfileError : Bool
    }


type Msg
    = SteamSignIn
