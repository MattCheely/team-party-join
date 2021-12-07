module Evergreen.V5.Pages.Home_ exposing (..)

import Evergreen.V5.Api.Data
import Evergreen.V5.Api.Steam
import Evergreen.V5.Api.Steam.SteamUser
import Set


type alias Model =
    { friends : Evergreen.V5.Api.Data.Data Evergreen.V5.Api.Steam.Error (List Evergreen.V5.Api.Steam.SteamUser.PlayerSummary)
    , selectedFriends : Set.Set Evergreen.V5.Api.Steam.SteamId
    }


type Msg
    = GotFriends (Evergreen.V5.Api.Data.Data Evergreen.V5.Api.Steam.Error (List Evergreen.V5.Api.Steam.SteamUser.PlayerSummary))
    | ToggleSelected Evergreen.V5.Api.Steam.SteamId
    | LookupGames
