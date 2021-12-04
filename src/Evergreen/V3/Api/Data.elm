module Evergreen.V3.Api.Data exposing (..)


type Data error value
    = NotAsked
    | Loading
    | Failure error
    | Success value
