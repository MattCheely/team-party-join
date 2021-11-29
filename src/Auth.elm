module Auth exposing (User, beforeProtectedInit)

import Api.Steam.SteamUser exposing (PlayerSummary)
import ElmSpa.Page as ElmSpa
import Gen.Route exposing (Route)
import Request exposing (Request)
import Shared exposing (UserStatus(..))


type alias User =
    PlayerSummary


beforeProtectedInit : Shared.Model -> Request -> ElmSpa.Protected PlayerSummary Route
beforeProtectedInit shared req =
    case shared.user of
        LoggedIn user ->
            ElmSpa.Provide user

        _ ->
            ElmSpa.RedirectTo Gen.Route.Login
