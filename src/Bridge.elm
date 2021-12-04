module Bridge exposing (..)

import Api.Steam exposing (SteamId)
import Lamdera


sendToBackend =
    Lamdera.sendToBackend


type ToBackend
    = LookupGames_SharedGames SteamId
    | GetFriendsList_Home SteamId
    | GetUserInfo_Shared SteamId
    | GetPlayerSummaries_SharedGames (List SteamId)
    | SignedOut
    | NoOpToBackend
