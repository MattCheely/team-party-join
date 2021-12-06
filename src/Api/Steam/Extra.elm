module Api.Steam.Extra exposing (AppMetaData, getExtraAppData)

import Http exposing (Error, expectJson, expectString, jsonBody)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value, object)


type alias AppMetaData =
    { appId : Int
    , name : String
    , categories : List String
    }


getExtraAppData : (Result Error (List AppMetaData) -> msg) -> List Int -> Cmd msg
getExtraAppData msg appIds =
    Http.post
        { url = "https://steam-to-sqlite.vercel.app/graphql"
        , body = jsonBody (queryFor appIds)
        , expect = expectJson msg responseDecoder
        }


queryFor : List Int -> Value
queryFor appIds =
    let
        query =
            "{steam_app(filter: {appid: {in: ["
                ++ String.join "," (List.map String.fromInt appIds)
                ++ "]}}) { nodes { name appid categorysteamapplink_list { nodes { category_pk { description_ }}}}}}"
    in
    object [ ( "query", Encode.string query ) ]


responseDecoder : Decoder (List AppMetaData)
responseDecoder =
    Decode.at [ "data", "steam_app", "nodes" ]
        (Decode.list
            (Decode.map3 AppMetaData
                (Decode.field "appid" Decode.int)
                (Decode.field "name" Decode.string)
                (Decode.at [ "categorysteamapplink_list", "nodes" ]
                    (Decode.list
                        (Decode.at [ "category_pk", "description_" ] Decode.string)
                    )
                )
            )
        )
