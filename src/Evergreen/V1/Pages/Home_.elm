module Evergreen.V1.Pages.Home_ exposing (..)

import Evergreen.V1.Api.Data
import Evergreen.V1.Api.Steam
import Evergreen.V1.Api.Steam.PlayerService


type alias Model =
    { steamId : String
    , gameList : Evergreen.V1.Api.Data.Data Evergreen.V1.Api.Steam.Error Evergreen.V1.Api.Steam.PlayerService.GameList
    }


type Msg
    = UpdatedSteamId String
    | LookupGames
    | GotGames (Evergreen.V1.Api.Data.Data Evergreen.V1.Api.Steam.Error Evergreen.V1.Api.Steam.PlayerService.GameList)
