module Evergreen.V3.Api.Steam.SteamUser exposing (..)

import Evergreen.V3.Api.Steam


type alias PlayerSummary =
    { steamId : Evergreen.V3.Api.Steam.SteamId
    , personaName : String
    , avatar : String
    , avatarMedium : String
    , avatarFull : String
    }
