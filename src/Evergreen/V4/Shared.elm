module Evergreen.V4.Shared exposing (..)

import Evergreen.V4.Api.Steam
import Evergreen.V4.Api.Steam.SteamUser
import Evergreen.V4.Gen.Route


type UserStatus
    = LoggedOut
    | LoggedIn Evergreen.V4.Api.Steam.SteamUser.PlayerSummary
    | ProfileError Evergreen.V4.Api.Steam.Error


type alias Model =
    { user : UserStatus
    , originalRoute : Evergreen.V4.Gen.Route.Route
    }


type Msg
    = ClickedSignOut
    | UserResult (Result Evergreen.V4.Api.Steam.Error Evergreen.V4.Api.Steam.SteamUser.PlayerSummary)
