module Evergreen.V2.Gen.Model exposing (..)

import Evergreen.V2.Gen.Params.Home_
import Evergreen.V2.Gen.Params.Login
import Evergreen.V2.Gen.Params.NotFound
import Evergreen.V2.Pages.Home_
import Evergreen.V2.Pages.Login


type Model
    = Redirecting_
    | Home_ Evergreen.V2.Gen.Params.Home_.Params Evergreen.V2.Pages.Home_.Model
    | Login Evergreen.V2.Gen.Params.Login.Params Evergreen.V2.Pages.Login.Model
    | NotFound Evergreen.V2.Gen.Params.NotFound.Params
