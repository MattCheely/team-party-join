module Evergreen.V7.Bridge exposing (..)

import Evergreen.V7.Api.Steam


type ToBackend
    = LookupGames_SharedGames Evergreen.V7.Api.Steam.SteamId
    | GetFriendsList_Home Evergreen.V7.Api.Steam.SteamId
    | GetUserInfo_Shared Evergreen.V7.Api.Steam.SteamId
    | GetPlayerSummaries_SharedGames (List Evergreen.V7.Api.Steam.SteamId)
    | SignedOut
