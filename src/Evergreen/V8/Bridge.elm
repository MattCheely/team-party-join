module Evergreen.V8.Bridge exposing (..)

import Evergreen.V8.Api.Steam


type ToBackend
    = LookupGames_SharedGames Evergreen.V8.Api.Steam.SteamId
    | GetFriendsList_Home Evergreen.V8.Api.Steam.SteamId
    | GetUserInfo_Shared Evergreen.V8.Api.Steam.SteamId
    | GetPlayerSummaries_SharedGames (List Evergreen.V8.Api.Steam.SteamId)
    | SignedOut
