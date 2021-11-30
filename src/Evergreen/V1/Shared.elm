module Evergreen.V1.Shared exposing (..)

import Evergreen.V1.Api.Steam
import Evergreen.V1.Api.Steam.SteamUser


type UserStatus
    = LoggedOut
    | LoggedIn Evergreen.V1.Api.Steam.SteamUser.PlayerSummary
    | ProfileError Evergreen.V1.Api.Steam.Error


type alias Model =
    { user : UserStatus
    }


type Msg
    = ClickedSignOut
    | UserResult (Result Evergreen.V1.Api.Steam.Error Evergreen.V1.Api.Steam.SteamUser.PlayerSummary)
