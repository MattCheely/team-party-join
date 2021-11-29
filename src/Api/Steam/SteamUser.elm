module Api.Steam.SteamUser exposing (PlayerSummary, getPlayerSummaries, getPlayerSummary)

import Api.Steam as Steam exposing (QueryParameter, SteamId, boolParam, stringParam)
import Http
import Json.Decode as Decode exposing (Decoder)


type alias PlayerSummary =
    { steamId : SteamId
    , personaName : String
    , avatar : String
    , avatarMedium : String
    , avatarFull : String
    }


getPlayerSummary : (Result Steam.Error PlayerSummary -> msg) -> SteamId -> Cmd msg
getPlayerSummary msg steamId =
    getPlayerSummaries
        (\result ->
            result
                |> Result.andThen
                    (\summaries ->
                        List.head summaries
                            |> Result.fromMaybe Steam.AccessDenied
                    )
                |> msg
        )
        [ steamId ]


getPlayerSummaries : (Result Steam.Error (List PlayerSummary) -> msg) -> List SteamId -> Cmd msg
getPlayerSummaries msg steamIds =
    Http.get
        { url =
            urlFor [ "GetPlayerSummaries", "v2" ]
                [ stringParam "steamids" (String.join "," steamIds) ]
        , expect =
            Steam.expectJson msg playerSummaryDecoder
        }


playerSummaryDecoder : Decoder (List PlayerSummary)
playerSummaryDecoder =
    Decode.at [ "response", "players" ]
        (Decode.list
            (Decode.map5 PlayerSummary
                (Decode.field "steamid" Decode.string)
                (Decode.field "personaname" Decode.string)
                (Decode.field "avatar" Decode.string)
                (Decode.field "avatarmedium" Decode.string)
                (Decode.field "avatarfull" Decode.string)
            )
        )


urlFor : List String -> List QueryParameter -> String
urlFor path query =
    Steam.urlFor ("ISteamUser" :: path) query
