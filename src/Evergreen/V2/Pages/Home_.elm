module Evergreen.V2.Pages.Home_ exposing (..)

import Dict
import Evergreen.V2.Api.Data
import Evergreen.V2.Api.Steam
import Evergreen.V2.Api.Steam.PlayerService


type alias Model =
    { steamIds : List String
    , gamesByUser : Dict.Dict String (Evergreen.V2.Api.Data.Data Evergreen.V2.Api.Steam.Error Evergreen.V2.Api.Steam.PlayerService.GameList)
    }


type Msg
    = UpdatedId Int String
    | NewSteamId String
    | LookupGames
    | GotGames String (Evergreen.V2.Api.Data.Data Evergreen.V2.Api.Steam.Error Evergreen.V2.Api.Steam.PlayerService.GameList)
