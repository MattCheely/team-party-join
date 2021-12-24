module Evergreen.V7.Pages.SharedGames.SteamIds_ exposing (..)

import Dict
import Evergreen.V7.Api.Data
import Evergreen.V7.Api.Steam
import Evergreen.V7.Api.Steam.PlayerService
import Evergreen.V7.Api.Steam.SteamUser
import Set


type alias PlayerData =
    { id : String
    , profile : Evergreen.V7.Api.Data.Data Evergreen.V7.Api.Steam.Error Evergreen.V7.Api.Steam.SteamUser.PlayerSummary
    , gameCount : Evergreen.V7.Api.Data.Data Evergreen.V7.Api.Steam.Error Int
    }


type alias Includes =
    { coOp : Bool
    , pvp : Bool
    , multiplayer : Bool
    , remotePlayTogether : Bool
    }


type alias GameData =
    { summary : Evergreen.V7.Api.Steam.PlayerService.GameSummary
    , ownedBy : Set.Set String
    }


type DisplayMode
    = MatchingGames
    | Overlap


type alias Model =
    { players : Dict.Dict String PlayerData
    , includes : Includes
    , games : Dict.Dict Int GameData
    , mode : DisplayMode
    }


type Msg
    = GotGames String (Evergreen.V7.Api.Data.Data Evergreen.V7.Api.Steam.Error Evergreen.V7.Api.Steam.PlayerService.GameList)
    | GotPlayerSummaries (Evergreen.V7.Api.Data.Data Evergreen.V7.Api.Steam.Error (List Evergreen.V7.Api.Steam.SteamUser.PlayerSummary))
    | SetCoOp Bool
    | SetPvP Bool
    | SetRemotePlay Bool
    | SetMultiplayer Bool
    | OverlapModeClicked
    | MatchingModeClicked
