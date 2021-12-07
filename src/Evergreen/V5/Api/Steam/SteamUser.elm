module Evergreen.V5.Api.Steam.SteamUser exposing (..)

import Evergreen.V5.Api.Steam


type alias PlayerSummary =
    { steamId : Evergreen.V5.Api.Steam.SteamId
    , personaName : String
    , avatar : String
    , avatarMedium : String
    , avatarFull : String
    }
