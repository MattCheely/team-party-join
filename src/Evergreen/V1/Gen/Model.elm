module Evergreen.V1.Gen.Model exposing (..)

import Evergreen.V1.Gen.Params.Home_
import Evergreen.V1.Gen.Params.Login
import Evergreen.V1.Gen.Params.NotFound
import Evergreen.V1.Pages.Home_
import Evergreen.V1.Pages.Login


type Model
    = Redirecting_
    | Home_ Evergreen.V1.Gen.Params.Home_.Params Evergreen.V1.Pages.Home_.Model
    | Login Evergreen.V1.Gen.Params.Login.Params Evergreen.V1.Pages.Login.Model
    | NotFound Evergreen.V1.Gen.Params.NotFound.Params
