module Evergreen.V5.Bridge exposing (..)

import Evergreen.V5.Api.Steam


type ToBackend
    = LookupGames_SharedGames Evergreen.V5.Api.Steam.SteamId
    | GetFriendsList_Home Evergreen.V5.Api.Steam.SteamId
    | GetUserInfo_Shared Evergreen.V5.Api.Steam.SteamId
    | GetPlayerSummaries_SharedGames (List Evergreen.V5.Api.Steam.SteamId)
    | SignedOut
    | NoOpToBackend
