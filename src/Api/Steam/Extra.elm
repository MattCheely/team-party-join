module Api.Steam.Extra exposing (AppMetaData, getExtraAppData)

import Http exposing (Error, expectJson, expectString, jsonBody)
import Http.Tasks as Tasks exposing (resolveJson)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value, object)
import Task exposing (Task)
import Url exposing (Url)
import Url.Builder exposing (crossOrigin, string)


type alias AppMetaData =
    { appId : Int
    , name : String
    , categories : List String
    }


getExtraAppData : List Int -> Task Error (List AppMetaData)
getExtraAppData appIds =
    Tasks.get
        { url = urlFor appIds
        , resolver = resolveJson responseDecoder
        }


urlFor : List Int -> String
urlFor appIds =
    crossOrigin "https://steam-to-sqlite.fly.dev"
        [ "database.json" ]
        [ string "sql" (queryFor appIds) ]


queryFor : List Int -> String
queryFor appIds =
    """select
  steam_app.name,
  steam_app.appid,
  steam_app.current_price,
  group_concat(category.description,"|--|") as Categories
from
  steam_app
  join categorysteamapplink on categorysteamapplink.steam_app_pk = steam_app.pk
  join category on category.pk = categorysteamapplink.category_pk
where
  steam_app.appid in (
     """
        ++ String.join "," (List.map String.fromInt appIds)
        ++ """)
group by
  steam_app.pk
order by
  steam_app.appid
         """


responseDecoder : Decoder (List AppMetaData)
responseDecoder =
    Decode.field "rows"
        (Decode.list
            (Decode.map3 AppMetaData
                (Decode.index 1 Decode.int)
                (Decode.index 0 Decode.string)
                (Decode.index 3 Decode.string
                    |> Decode.map (String.split "|--|")
                )
            )
        )
