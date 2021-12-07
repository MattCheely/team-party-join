module Evergreen.V5.Gen.Model exposing (..)

import Evergreen.V5.Gen.Params.Home_
import Evergreen.V5.Gen.Params.Login
import Evergreen.V5.Gen.Params.NotFound
import Evergreen.V5.Gen.Params.SharedGames.SteamIds_
import Evergreen.V5.Pages.Home_
import Evergreen.V5.Pages.Login
import Evergreen.V5.Pages.SharedGames.SteamIds_


type Model
    = Redirecting_
    | Home_ Evergreen.V5.Gen.Params.Home_.Params Evergreen.V5.Pages.Home_.Model
    | Login Evergreen.V5.Gen.Params.Login.Params Evergreen.V5.Pages.Login.Model
    | NotFound Evergreen.V5.Gen.Params.NotFound.Params
    | SharedGames__SteamIds_ Evergreen.V5.Gen.Params.SharedGames.SteamIds_.Params Evergreen.V5.Pages.SharedGames.SteamIds_.Model
