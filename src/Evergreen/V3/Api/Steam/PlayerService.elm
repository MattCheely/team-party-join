module Evergreen.V3.Api.Steam.PlayerService exposing (..)


type alias GameSummary =
    { appId : Int
    , name : String
    , iconUrl : String
    , logoUrl : String
    }


type alias GameList =
    { gameCount : Int
    , games : List GameSummary
    }
