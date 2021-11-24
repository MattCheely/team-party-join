module Evergreen.V1.Pages.Profile.Username_ exposing (..)

import Evergreen.V1.Api.Data
import Evergreen.V1.Api.Profile
import Evergreen.V1.Api.User


type Tab
    = MyArticles
    | FavoritedArticles


type alias Model =
    { username : String
    , profile : Evergreen.V1.Api.Data.Data (List String) Evergreen.V1.Api.Profile.Profile
    , selectedTab : Tab
    , page : Int
    }


type Msg
    = GotProfile (Evergreen.V1.Api.Data.Data (List String) Evergreen.V1.Api.Profile.Profile)
    | Clicked Tab
    | ClickedFollow Evergreen.V1.Api.User.User Evergreen.V1.Api.Profile.Profile
    | ClickedUnfollow Evergreen.V1.Api.User.User Evergreen.V1.Api.Profile.Profile
    | ClickedPage Int
