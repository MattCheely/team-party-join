module Evergreen.V5.Pages.SharedGames.SteamIds_ exposing (..)

import Dict
import Evergreen.V5.Api.Data
import Evergreen.V5.Api.Steam
import Evergreen.V5.Api.Steam.PlayerService
import Evergreen.V5.Api.Steam.SteamUser
import Set


type alias PlayerData =
    { profile : Evergreen.V5.Api.Data.Data Evergreen.V5.Api.Steam.Error Evergreen.V5.Api.Steam.SteamUser.PlayerSummary
    , gameCount : Evergreen.V5.Api.Data.Data Evergreen.V5.Api.Steam.Error Int
    }


type alias GameData =
    { summary : Evergreen.V5.Api.Steam.PlayerService.GameSummary
    , ownedBy : Set.Set String
    }


type alias Model =
    { players : Dict.Dict String PlayerData
    , games : Dict.Dict Int GameData
    }


type Msg
    = GotGames String (Evergreen.V5.Api.Data.Data Evergreen.V5.Api.Steam.Error Evergreen.V5.Api.Steam.PlayerService.GameList)
    | GotPlayerSummaries (Evergreen.V5.Api.Data.Data Evergreen.V5.Api.Steam.Error (List Evergreen.V5.Api.Steam.SteamUser.PlayerSummary))
