module Evergreen.V5.Api.Steam.PlayerService exposing (..)

import Set


type alias GameSummary =
    { appId : Int
    , name : String
    , iconUrl : String
    , logoUrl : String
    , categories : Set.Set String
    }


type alias GameList =
    { gameCount : Int
    , games : List GameSummary
    }
