module Evergreen.V3.Shared exposing (..)

import Evergreen.V3.Api.Steam
import Evergreen.V3.Api.Steam.SteamUser


type UserStatus
    = LoggedOut
    | LoggedIn Evergreen.V3.Api.Steam.SteamUser.PlayerSummary
    | ProfileError Evergreen.V3.Api.Steam.Error


type alias Model =
    { user : UserStatus
    }


type Msg
    = ClickedSignOut
    | UserResult (Result Evergreen.V3.Api.Steam.Error Evergreen.V3.Api.Steam.SteamUser.PlayerSummary)
