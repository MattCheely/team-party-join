module Evergreen.V8.Gen.Route exposing (..)


type Route
    = Home_
    | Login
    | NotFound
    | SharedGames__SteamIds_
        { steamIds : String
        }
