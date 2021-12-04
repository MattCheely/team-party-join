module Evergreen.V4.Api.Steam.SteamUser exposing (..)

import Evergreen.V4.Api.Steam


type alias PlayerSummary =
    { steamId : Evergreen.V4.Api.Steam.SteamId
    , personaName : String
    , avatar : String
    , avatarMedium : String
    , avatarFull : String
    }
