module Api.Steam.SteamUser exposing (FriendInfo, PlayerSummary, getFriendList, getFriendListDetails, getPlayerSummaries, getPlayerSummary)

import Api.Steam as Steam exposing (QueryParameter, SteamId, stringParam)
import Http
import Json.Decode as Decode exposing (Decoder)
import Task


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
        { url = playerSummariesUrl steamIds
        , expect =
            Steam.expectJson msg playerSummaryDecoder
        }


playerSummariesUrl : List SteamId -> String
playerSummariesUrl steamIds =
    urlFor [ "GetPlayerSummaries", "v2" ]
        [ stringParam "steamids" (String.join "," steamIds) ]


type alias FriendInfo =
    { steamId : String
    , relationship : String
    , friendSince : Int
    }


getFriendList : (Result Steam.Error (List FriendInfo) -> msg) -> SteamId -> Cmd msg
getFriendList msg steamId =
    Http.get
        { url = friendListUrl steamId
        , expect =
            Steam.expectJson msg friendListDecoder
        }


getFriendListDetails : (Result Steam.Error (List PlayerSummary) -> msg) -> SteamId -> Cmd msg
getFriendListDetails msg steamId =
    Steam.taskGet { url = friendListUrl steamId, decoder = friendListDecoder }
        |> Task.andThen
            (\friends ->
                Steam.taskGet
                    { url = playerSummariesUrl (List.map .steamId friends)
                    , decoder = playerSummaryDecoder
                    }
            )
        |> Task.attempt msg


friendListUrl : SteamId -> String
friendListUrl steamId =
    urlFor [ "GetFriendList", "v1" ]
        [ stringParam "steamid" steamId, stringParam "relationship" "friend" ]


friendListDecoder : Decoder (List FriendInfo)
friendListDecoder =
    Decode.at [ "friendslist", "friends" ]
        (Decode.list
            (Decode.map3 FriendInfo
                (Decode.field "steamid" Decode.string)
                (Decode.field "relationship" Decode.string)
                (Decode.field "friend_since" Decode.int)
            )
        )


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
