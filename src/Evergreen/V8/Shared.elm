module Evergreen.V8.Shared exposing (..)

import Evergreen.V8.Api.Steam
import Evergreen.V8.Api.Steam.SteamUser
import Evergreen.V8.Gen.Route


type UserStatus
    = LoggedOut
    | LoggedIn Evergreen.V8.Api.Steam.SteamUser.PlayerSummary
    | ProfileError Evergreen.V8.Api.Steam.Error


type alias Model =
    { user : UserStatus
    , originalRoute : Evergreen.V8.Gen.Route.Route
    }


type Msg
    = ClickedSignOut
    | UserResult (Result Evergreen.V8.Api.Steam.Error Evergreen.V8.Api.Steam.SteamUser.PlayerSummary)
