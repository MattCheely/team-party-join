module Evergreen.V4.Gen.Route exposing (..)


type Route
    = Home_
    | Login
    | NotFound
    | SharedGames__SteamIds_
        { steamIds : String
        }
