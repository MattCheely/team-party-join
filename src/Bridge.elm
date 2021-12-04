module Bridge exposing (..)

import Api.Steam exposing (SteamId)
import Lamdera


sendToBackend =
    Lamdera.sendToBackend


type ToBackend
    = LookupGames_Home SteamId
    | GetFriendsList_Home SteamId
    | GetUserInfo_Shared SteamId
    | SignedOut
    | NoOpToBackend
