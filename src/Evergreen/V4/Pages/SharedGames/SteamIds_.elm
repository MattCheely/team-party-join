module Evergreen.V4.Pages.SharedGames.SteamIds_ exposing (..)

import Dict
import Evergreen.V4.Api.Data
import Evergreen.V4.Api.Steam
import Evergreen.V4.Api.Steam.PlayerService
import Evergreen.V4.Api.Steam.SteamUser


type alias PlayerData =
    { profile : Evergreen.V4.Api.Data.Data Evergreen.V4.Api.Steam.Error Evergreen.V4.Api.Steam.SteamUser.PlayerSummary
    , games : Evergreen.V4.Api.Data.Data Evergreen.V4.Api.Steam.Error Evergreen.V4.Api.Steam.PlayerService.GameList
    }


type alias Model =
    { players : Dict.Dict String PlayerData
    }


type Msg
    = GotGames String (Evergreen.V4.Api.Data.Data Evergreen.V4.Api.Steam.Error Evergreen.V4.Api.Steam.PlayerService.GameList)
    | GotPlayerSummaries (Evergreen.V4.Api.Data.Data Evergreen.V4.Api.Steam.Error (List Evergreen.V4.Api.Steam.SteamUser.PlayerSummary))
