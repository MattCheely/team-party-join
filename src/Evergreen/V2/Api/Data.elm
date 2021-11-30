module Evergreen.V2.Api.Data exposing (..)


type Data error value
    = NotAsked
    | Loading
    | Failure error
    | Success value
