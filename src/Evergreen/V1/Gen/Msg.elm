module Evergreen.V1.Gen.Msg exposing (..)

import Evergreen.V1.Pages.Home_
import Evergreen.V1.Pages.Login


type Msg
    = Home_ Evergreen.V1.Pages.Home_.Msg
    | Login Evergreen.V1.Pages.Login.Msg
