module Gen.Params.SharedGames.SteamIds_ exposing (Params, parser)

import Url.Parser as Parser exposing ((</>), Parser)


type alias Params =
    { steamIds : String }


parser =
    Parser.map Params (Parser.s "shared-games" </> Parser.string)

