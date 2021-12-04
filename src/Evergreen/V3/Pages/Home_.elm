module Evergreen.V3.Pages.Home_ exposing (..)

import Dict
import Evergreen.V3.Api.Data
import Evergreen.V3.Api.Steam
import Evergreen.V3.Api.Steam.PlayerService
import Evergreen.V3.Api.Steam.SteamUser
import Set


type alias Model =
    { friends : Evergreen.V3.Api.Data.Data Evergreen.V3.Api.Steam.Error (List Evergreen.V3.Api.Steam.SteamUser.PlayerSummary)
    , selectedFriends : Set.Set Evergreen.V3.Api.Steam.SteamId
    , gamesByUser : Dict.Dict String (Evergreen.V3.Api.Data.Data Evergreen.V3.Api.Steam.Error Evergreen.V3.Api.Steam.PlayerService.GameList)
    }


type Msg
    = GotFriends (Evergreen.V3.Api.Data.Data Evergreen.V3.Api.Steam.Error (List Evergreen.V3.Api.Steam.SteamUser.PlayerSummary))
    | ToggleSelected Evergreen.V3.Api.Steam.SteamId
    | LookupGames
    | GotGames String (Evergreen.V3.Api.Data.Data Evergreen.V3.Api.Steam.Error Evergreen.V3.Api.Steam.PlayerService.GameList)
