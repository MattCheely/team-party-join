module Evergreen.V8.Api.Data exposing (..)


type Data error value
    = NotAsked
    | Loading
    | Failure error
    | Success value
