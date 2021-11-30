module Evergreen.V2.Shared exposing (..)

import Evergreen.V2.Api.Steam
import Evergreen.V2.Api.Steam.SteamUser


type UserStatus
    = LoggedOut
    | LoggedIn Evergreen.V2.Api.Steam.SteamUser.PlayerSummary
    | ProfileError Evergreen.V2.Api.Steam.Error


type alias Model =
    { user : UserStatus
    }


type Msg
    = ClickedSignOut
    | UserResult (Result Evergreen.V2.Api.Steam.Error Evergreen.V2.Api.Steam.SteamUser.PlayerSummary)
