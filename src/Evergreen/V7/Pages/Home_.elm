module Evergreen.V7.Pages.Home_ exposing (..)

import Evergreen.V7.Api.Data
import Evergreen.V7.Api.Steam
import Evergreen.V7.Api.Steam.SteamUser
import Set


type alias Model =
    { friends : Evergreen.V7.Api.Data.Data Evergreen.V7.Api.Steam.Error (List Evergreen.V7.Api.Steam.SteamUser.PlayerSummary)
    , selectedFriends : Set.Set Evergreen.V7.Api.Steam.SteamId
    }


type Msg
    = GotFriends (Evergreen.V7.Api.Data.Data Evergreen.V7.Api.Steam.Error (List Evergreen.V7.Api.Steam.SteamUser.PlayerSummary))
    | ToggleSelected Evergreen.V7.Api.Steam.SteamId
    | LookupGames
