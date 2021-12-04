module Evergreen.V4.Pages.Home_ exposing (..)

import Evergreen.V4.Api.Data
import Evergreen.V4.Api.Steam
import Evergreen.V4.Api.Steam.SteamUser
import Set


type alias Model =
    { friends : Evergreen.V4.Api.Data.Data Evergreen.V4.Api.Steam.Error (List Evergreen.V4.Api.Steam.SteamUser.PlayerSummary)
    , selectedFriends : Set.Set Evergreen.V4.Api.Steam.SteamId
    }


type Msg
    = GotFriends (Evergreen.V4.Api.Data.Data Evergreen.V4.Api.Steam.Error (List Evergreen.V4.Api.Steam.SteamUser.PlayerSummary))
    | ToggleSelected Evergreen.V4.Api.Steam.SteamId
    | LookupGames
