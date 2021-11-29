module Utils.Url exposing (domain)

import Url exposing (Url)


domain : Url -> Url
domain url =
    { url | path = "", query = Nothing, fragment = Nothing }
