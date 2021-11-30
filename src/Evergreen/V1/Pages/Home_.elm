module Evergreen.V1.Pages.Home_ exposing (..)

import Dict
import Evergreen.V1.Api.Data
import Evergreen.V1.Api.Steam
import Evergreen.V1.Api.Steam.PlayerService


type alias Model =
    { steamIds : List String
    , gamesByUser : Dict.Dict String (Evergreen.V1.Api.Data.Data Evergreen.V1.Api.Steam.Error Evergreen.V1.Api.Steam.PlayerService.GameList)
    }


type Msg
    = UpdatedId Int String
    | NewSteamId String
    | LookupGames
    | GotGames String (Evergreen.V1.Api.Data.Data Evergreen.V1.Api.Steam.Error Evergreen.V1.Api.Steam.PlayerService.GameList)
