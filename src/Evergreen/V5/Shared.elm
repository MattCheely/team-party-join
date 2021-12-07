module Evergreen.V5.Shared exposing (..)

import Evergreen.V5.Api.Steam
import Evergreen.V5.Api.Steam.SteamUser
import Evergreen.V5.Gen.Route


type UserStatus
    = LoggedOut
    | LoggedIn Evergreen.V5.Api.Steam.SteamUser.PlayerSummary
    | ProfileError Evergreen.V5.Api.Steam.Error


type alias Model =
    { user : UserStatus
    , originalRoute : Evergreen.V5.Gen.Route.Route
    }


type Msg
    = ClickedSignOut
    | UserResult (Result Evergreen.V5.Api.Steam.Error Evergreen.V5.Api.Steam.SteamUser.PlayerSummary)
