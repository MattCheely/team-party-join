module Api.Steam.PlayerService exposing (GameList, GameSummary, getOwnedGames)

import Api.Steam as Steam exposing (QueryParameter, SteamId, boolParam, stringParam)
import Http
import Json.Decode as Decode exposing (Decoder)


type alias GameList =
    { gameCount : Int
    , games : List GameSummary
    }


type alias GameSummary =
    { appId : Int
    , name : String
    , iconUrl : String
    , logoUrl : String
    }


{-| Return a list of games owned by the player
-}
getOwnedGames :
    (Result Steam.Error GameList -> msg)
    -> { steamId : SteamId }
    -> Cmd msg
getOwnedGames msg params =
    Http.get
        { url =
            urlFor [ "GetOwnedGames", "v1" ]
                [ stringParam "steamid" params.steamId
                , boolParam "include_appinfo" True
                , boolParam "inlcude_played_free_games" True

                -- Skipping appids_filter because I don't want to write a query encoder
                -- for lists until we actually need it
                ]
        , expect = Steam.expectJson msg gameListDecoder
        }


{-| Generates a PlayerService request with the appropriate origin and API key
-}
urlFor : List String -> List QueryParameter -> String
urlFor path =
    Steam.urlFor ("IPlayerService" :: path)



-- JSON Encoder/Decoders


gameListDecoder : Decoder GameList
gameListDecoder =
    Decode.field "response" <|
        Decode.map2 GameList
            (Decode.field "game_count" Decode.int)
            (Decode.field "games" (Decode.list gameSummaryDecoder))


gameSummaryDecoder : Decoder GameSummary
gameSummaryDecoder =
    Decode.field "appid" Decode.int
        |> Decode.andThen
            (\appId ->
                Decode.map4 GameSummary
                    (Decode.succeed appId)
                    (Decode.field "name" Decode.string)
                    (Decode.field "img_icon_url" Decode.string
                        |> Decode.map (imgUrl appId)
                    )
                    (Decode.field "img_logo_url" Decode.string
                        |> Decode.map (imgUrl appId)
                    )
            )


imgUrl : Int -> String -> String
imgUrl appId hash =
    "http://media.steampowered.com/steamcommunity/public/images/apps/" ++ String.fromInt appId ++ "/" ++ hash ++ ".jpg"
