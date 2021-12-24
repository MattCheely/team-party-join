module Evergreen.V7.Api.Steam.SteamUser exposing (..)

import Evergreen.V7.Api.Steam


type alias PlayerSummary =
    { steamId : Evergreen.V7.Api.Steam.SteamId
    , personaName : String
    , avatar : String
    , avatarMedium : String
    , avatarFull : String
    }
