module Evergreen.V4.Gen.Model exposing (..)

import Evergreen.V4.Gen.Params.Home_
import Evergreen.V4.Gen.Params.Login
import Evergreen.V4.Gen.Params.NotFound
import Evergreen.V4.Gen.Params.SharedGames.SteamIds_
import Evergreen.V4.Pages.Home_
import Evergreen.V4.Pages.Login
import Evergreen.V4.Pages.SharedGames.SteamIds_


type Model
    = Redirecting_
    | Home_ Evergreen.V4.Gen.Params.Home_.Params Evergreen.V4.Pages.Home_.Model
    | Login Evergreen.V4.Gen.Params.Login.Params Evergreen.V4.Pages.Login.Model
    | NotFound Evergreen.V4.Gen.Params.NotFound.Params
    | SharedGames__SteamIds_ Evergreen.V4.Gen.Params.SharedGames.SteamIds_.Params Evergreen.V4.Pages.SharedGames.SteamIds_.Model
