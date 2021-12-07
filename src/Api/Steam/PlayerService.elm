module Api.Steam.PlayerService exposing (GameList, GameSummary, getOwnedGames)

import Api.Steam as Steam exposing (QueryParameter, SteamId, boolParam, stringParam)
import Api.Steam.Extra as Extra exposing (AppMetaData)
import Dict exposing (Dict)
import Http
import Json.Decode as Decode exposing (Decoder)
import Set exposing (Set)
import Task exposing (Task)


type alias GameList =
    { gameCount : Int
    , games : List GameSummary
    }


type alias GameSummary =
    { appId : Int
    , name : String
    , iconUrl : String
    , logoUrl : String
    , categories : Set String
    }


{-| Return a list of games owned by the player
-}
getOwnedGames :
    (Result Steam.Error GameList -> msg)
    -> { steamId : SteamId }
    -> Cmd msg
getOwnedGames msg params =
    Steam.taskGet
        { url =
            urlFor [ "GetOwnedGames", "v1" ]
                [ stringParam "steamid" params.steamId
                , boolParam "include_appinfo" True
                , boolParam "inlcude_played_free_games" True

                -- Skipping appids_filter because I don't want to write a query encoder
                -- for lists until we actually need it
                ]
        , decoder = gameListDecoder
        }
        |> Task.andThen addCategories
        |> Task.attempt msg


addCategories : GameList -> Task Steam.Error GameList
addCategories gameList =
    let
        ids =
            List.map .appId gameList.games
    in
    Extra.getExtraAppData ids
        |> Task.map (mergeMetadata gameList)
        |> Task.mapError (always Steam.InternalError)


mergeMetadata : GameList -> List AppMetaData -> GameList
mergeMetadata gameList metadata =
    let
        metadataDict =
            List.map (\data -> ( data.appId, data )) metadata
                |> Dict.fromList

        games =
            gameList.games
                |> List.map
                    (\summary ->
                        { summary
                            | categories =
                                Dict.get summary.appId metadataDict
                                    |> Maybe.map .categories
                                    |> Maybe.withDefault []
                                    |> Set.fromList
                        }
                    )
    in
    { gameList | games = games }


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
                Decode.map5 GameSummary
                    (Decode.succeed appId)
                    (Decode.field "name" Decode.string)
                    (Decode.field "img_icon_url" Decode.string
                        |> Decode.map (imgUrl appId)
                    )
                    (Decode.field "img_logo_url" Decode.string
                        |> Decode.map (imgUrl appId)
                    )
                    (Decode.succeed Set.empty)
            )


imgUrl : Int -> String -> String
imgUrl appId hash =
    "http://media.steampowered.com/steamcommunity/public/images/apps/" ++ String.fromInt appId ++ "/" ++ hash ++ ".jpg"
