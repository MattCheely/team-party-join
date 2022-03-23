module Evergreen.V8.Pages.Home_ exposing (..)

import Evergreen.V8.Api.Data
import Evergreen.V8.Api.Steam
import Evergreen.V8.Api.Steam.SteamUser
import Set


type alias Model =
    { friends : Evergreen.V8.Api.Data.Data Evergreen.V8.Api.Steam.Error (List Evergreen.V8.Api.Steam.SteamUser.PlayerSummary)
    , selectedFriends : Set.Set Evergreen.V8.Api.Steam.SteamId
    }


type Msg
    = GotFriends (Evergreen.V8.Api.Data.Data Evergreen.V8.Api.Steam.Error (List Evergreen.V8.Api.Steam.SteamUser.PlayerSummary))
    | ToggleSelected Evergreen.V8.Api.Steam.SteamId
    | LookupGames
