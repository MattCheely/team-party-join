module Evergreen.V1.Gen.Model exposing (..)

import Evergreen.V1.Gen.Params.Home_
import Evergreen.V1.Gen.Params.Login
import Evergreen.V1.Gen.Params.NotFound
import Evergreen.V1.Gen.Params.Profile.Username_
import Evergreen.V1.Gen.Params.Register
import Evergreen.V1.Gen.Params.Settings
import Evergreen.V1.Pages.Home_
import Evergreen.V1.Pages.Login
import Evergreen.V1.Pages.Profile.Username_
import Evergreen.V1.Pages.Register
import Evergreen.V1.Pages.Settings


type Model
    = Redirecting_
    | Home_ Evergreen.V1.Gen.Params.Home_.Params Evergreen.V1.Pages.Home_.Model
    | Login Evergreen.V1.Gen.Params.Login.Params Evergreen.V1.Pages.Login.Model
    | NotFound Evergreen.V1.Gen.Params.NotFound.Params
    | Register Evergreen.V1.Gen.Params.Register.Params Evergreen.V1.Pages.Register.Model
    | Settings Evergreen.V1.Gen.Params.Settings.Params Evergreen.V1.Pages.Settings.Model
    | Profile__Username_ Evergreen.V1.Gen.Params.Profile.Username_.Params Evergreen.V1.Pages.Profile.Username_.Model
