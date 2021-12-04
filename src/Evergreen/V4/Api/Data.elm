module Evergreen.V4.Api.Data exposing (..)


type Data error value
    = NotAsked
    | Loading
    | Failure error
    | Success value
