module Evergreen.V3.Gen.Model exposing (..)

import Evergreen.V3.Gen.Params.Home_
import Evergreen.V3.Gen.Params.Login
import Evergreen.V3.Gen.Params.NotFound
import Evergreen.V3.Pages.Home_
import Evergreen.V3.Pages.Login


type Model
    = Redirecting_
    | Home_ Evergreen.V3.Gen.Params.Home_.Params Evergreen.V3.Pages.Home_.Model
    | Login Evergreen.V3.Gen.Params.Login.Params Evergreen.V3.Pages.Login.Model
    | NotFound Evergreen.V3.Gen.Params.NotFound.Params
