module Bridge exposing (..)

import Api.Steam exposing (SteamId)
import Lamdera


sendToBackend =
    Lamdera.sendToBackend


type ToBackend
    = LookupGames_Home { steamId : String }
    | GetUserInfo_Shared SteamId
    | SignedOut
    | NoOpToBackend
