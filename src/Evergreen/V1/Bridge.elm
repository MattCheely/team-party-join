module Evergreen.V1.Bridge exposing (..)

import Evergreen.V1.Api.User


type ToBackend
    = LookupGames_Home
        { steamId : String
        }
    | SignedOut Evergreen.V1.Api.User.User
    | ProfileGet_Profile__Username_
        { username : String
        }
    | ProfileFollow_Profile__Username_
        { username : String
        }
    | ProfileUnfollow_Profile__Username_
        { username : String
        }
    | UserAuthentication_Login
        { params :
            { email : String
            , password : String
            }
        }
    | UserRegistration_Register
        { params :
            { username : String
            , email : String
            , password : String
            }
        }
    | UserUpdate_Settings
        { params :
            { username : String
            , email : String
            , password : Maybe String
            , image : String
            , bio : String
            }
        }
    | NoOpToBackend
