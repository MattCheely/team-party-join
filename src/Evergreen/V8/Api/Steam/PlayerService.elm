module Evergreen.V8.Api.Steam.PlayerService exposing (..)

import Set


type alias GameSummary =
    { appId : Int
    , name : String
    , iconUrl : String
    , categories : Set.Set String
    }


type alias GameList =
    { gameCount : Int
    , games : List GameSummary
    }
