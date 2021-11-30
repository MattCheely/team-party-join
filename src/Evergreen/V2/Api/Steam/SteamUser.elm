module Evergreen.V2.Api.Steam.SteamUser exposing (..)

import Evergreen.V2.Api.Steam


type alias PlayerSummary =
    { steamId : Evergreen.V2.Api.Steam.SteamId
    , personaName : String
    , avatar : String
    , avatarMedium : String
    , avatarFull : String
    }
