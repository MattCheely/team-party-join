module Evergreen.V7.Shared exposing (..)

import Evergreen.V7.Api.Steam
import Evergreen.V7.Api.Steam.SteamUser
import Evergreen.V7.Gen.Route


type UserStatus
    = LoggedOut
    | LoggedIn Evergreen.V7.Api.Steam.SteamUser.PlayerSummary
    | ProfileError Evergreen.V7.Api.Steam.Error


type alias Model =
    { user : UserStatus
    , originalRoute : Evergreen.V7.Gen.Route.Route
    }


type Msg
    = ClickedSignOut
    | UserResult (Result Evergreen.V7.Api.Steam.Error Evergreen.V7.Api.Steam.SteamUser.PlayerSummary)
