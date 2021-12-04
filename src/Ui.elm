module Ui exposing (playerCard)

import Html exposing (Attribute, Html, div, img, text)
import Html.Attributes exposing (alt, class, src)


playerCard :
    List (Attribute msg)
    -> { avatar : String, name : String, note : String }
    -> Html msg
playerCard attrs player =
    div
        (class "d-inline-flex align-items-center"
            :: class "border rounded p-10"
            :: attrs
        )
        [ img
            [ class "rounded-circle w-50"
            , src player.avatar
            , alt ""
            ]
            []
        , div [ class "ml-10" ]
            [ div [ class "font-size-16" ] [ text player.name ]
            , div [ class "font-size-12" ] [ text player.note ]
            ]
        ]
