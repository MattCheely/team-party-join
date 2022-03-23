module Evergreen.V8.Pages.SharedGames.SteamIds_ exposing (..)

import Dict
import Evergreen.V8.Api.Data
import Evergreen.V8.Api.Steam
import Evergreen.V8.Api.Steam.PlayerService
import Evergreen.V8.Api.Steam.SteamUser
import Set


type alias PlayerData =
    { id : String
    , profile : Evergreen.V8.Api.Data.Data Evergreen.V8.Api.Steam.Error Evergreen.V8.Api.Steam.SteamUser.PlayerSummary
    , gameCount : Evergreen.V8.Api.Data.Data Evergreen.V8.Api.Steam.Error Int
    }


type alias Includes =
    { coOp : Bool
    , pvp : Bool
    , multiplayer : Bool
    , remotePlayTogether : Bool
    }


type alias GameData =
    { summary : Evergreen.V8.Api.Steam.PlayerService.GameSummary
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
    = GotGames String (Evergreen.V8.Api.Data.Data Evergreen.V8.Api.Steam.Error Evergreen.V8.Api.Steam.PlayerService.GameList)
    | GotPlayerSummaries (Evergreen.V8.Api.Data.Data Evergreen.V8.Api.Steam.Error (List Evergreen.V8.Api.Steam.SteamUser.PlayerSummary))
    | SetCoOp Bool
    | SetPvP Bool
    | SetRemotePlay Bool
    | SetMultiplayer Bool
    | OverlapModeClicked
    | MatchingModeClicked
