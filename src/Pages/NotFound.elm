module Pages.NotFound exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, href)


view : { title : String, body : List (Html msg) }
view =
    { title = "404"
    , body =
        [ div [ class "container page" ]
            [ h2 [] [ text "Page not found." ]
            , h5 []
                [ text "But here's the "
                , a [ href "/" ] [ text "homepage" ]
                , text "!"
                ]
            ]
        ]
    }
