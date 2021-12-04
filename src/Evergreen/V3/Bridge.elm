module Evergreen.V3.Bridge exposing (..)

import Evergreen.V3.Api.Steam


type ToBackend
    = LookupGames_Home Evergreen.V3.Api.Steam.SteamId
    | GetFriendsList_Home Evergreen.V3.Api.Steam.SteamId
    | GetUserInfo_Shared Evergreen.V3.Api.Steam.SteamId
    | SignedOut
    | NoOpToBackend
