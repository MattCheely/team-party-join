module Evergreen.V1.Api.Data exposing (..)


type Data error value
    = NotAsked
    | Loading
    | Failure error
    | Success value
