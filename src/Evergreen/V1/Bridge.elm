module Evergreen.V1.Bridge exposing (..)

import Evergreen.V1.Api.Steam


type ToBackend
    = LookupGames_Home
        { steamId : String
        }
    | GetUserInfo_Shared Evergreen.V1.Api.Steam.SteamId
    | SignedOut
    | NoOpToBackend
