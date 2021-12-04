module Evergreen.V4.Bridge exposing (..)

import Evergreen.V4.Api.Steam


type ToBackend
    = LookupGames_SharedGames Evergreen.V4.Api.Steam.SteamId
    | GetFriendsList_Home Evergreen.V4.Api.Steam.SteamId
    | GetUserInfo_Shared Evergreen.V4.Api.Steam.SteamId
    | GetPlayerSummaries_SharedGames (List Evergreen.V4.Api.Steam.SteamId)
    | SignedOut
    | NoOpToBackend
