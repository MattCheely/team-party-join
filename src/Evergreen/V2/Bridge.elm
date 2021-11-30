module Evergreen.V2.Bridge exposing (..)

import Evergreen.V2.Api.Steam


type ToBackend
    = LookupGames_Home
        { steamId : String
        }
    | GetUserInfo_Shared Evergreen.V2.Api.Steam.SteamId
    | SignedOut
    | NoOpToBackend
