module Evergreen.V8.Api.Steam.SteamUser exposing (..)

import Evergreen.V8.Api.Steam


type alias PlayerSummary =
    { steamId : Evergreen.V8.Api.Steam.SteamId
    , personaName : String
    , avatar : String
    , avatarMedium : String
    , avatarFull : String
    }
