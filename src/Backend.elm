module Backend exposing (..)

import Api.Data as Data exposing (Data(..))
import Api.Profile exposing (Profile)
import Api.Steam.PlayerService as PlayerService
import Api.User exposing (Email, UserFull)
import Bridge exposing (..)
import Dict
import Dict.Extra as Dict
import Gen.Msg
import Lamdera exposing (..)
import List.Extra as List
import Pages.Home_
import Pages.Login
import Pages.Profile.Username_
import Pages.Register
import Pages.Settings
import Task
import Time
import Time.Extra as Time
import Types exposing (BackendModel, BackendMsg(..), FrontendMsg(..), ToFrontend(..))


type alias Model =
    BackendModel


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = \m -> onConnect CheckSession
        }


init : ( Model, Cmd BackendMsg )
init =
    ( { sessions = Dict.empty
      , users = Dict.empty
      }
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        GotGames_Home cid steamId response ->
            ( model
            , sendToFrontend cid
                (PageMsg
                    (Gen.Msg.Home_
                        (Pages.Home_.GotGames steamId
                            (Data.fromResult response)
                        )
                    )
                )
            )

        CheckSession sid cid ->
            model
                |> getSessionUser sid
                |> Maybe.map (\user -> ( model, sendToFrontend cid (ActiveSession (Api.User.toUser user)) ))
                |> Maybe.withDefault ( model, Cmd.none )

        RenewSession uid sid cid now ->
            ( { model | sessions = model.sessions |> Dict.update sid (always (Just { userId = uid, expires = now |> Time.add Time.Day 30 Time.utc })) }
            , Time.now |> Task.perform (always (CheckSession sid cid))
            )

        NoOpBackendMsg ->
            ( model, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    let
        send v =
            ( model, send_ v )

        send_ v =
            sendToFrontend clientId v
    in
    case msg of
        LookupGames_Home params ->
            ( model
            , PlayerService.getOwnedGames
                (GotGames_Home clientId params.steamId)
                { steamId = params.steamId }
            )

        SignedOut user ->
            ( { model | sessions = model.sessions |> Dict.remove sessionId }, Cmd.none )

        ProfileGet_Profile__Username_ { username } ->
            let
                res =
                    profileByUsername username model
                        |> Maybe.map Success
                        |> Maybe.withDefault (Failure [ "user not found" ])
            in
            send (PageMsg (Gen.Msg.Profile__Username_ (Pages.Profile.Username_.GotProfile res)))

        ProfileFollow_Profile__Username_ { username } ->
            followUser sessionId
                username
                model
                (\r -> send_ (PageMsg (Gen.Msg.Profile__Username_ (Pages.Profile.Username_.GotProfile r))))

        ProfileUnfollow_Profile__Username_ { username } ->
            unfollowUser sessionId
                username
                model
                (\r -> send_ (PageMsg (Gen.Msg.Profile__Username_ (Pages.Profile.Username_.GotProfile r))))

        UserAuthentication_Login { params } ->
            let
                ( response, cmd ) =
                    model.users
                        |> Dict.find (\k u -> u.email == params.email)
                        |> Maybe.map
                            (\( k, u ) ->
                                if u.password == params.password then
                                    ( Success (Api.User.toUser u), renewSession u.id sessionId clientId )

                                else
                                    ( Failure [ "email or password is invalid" ], Cmd.none )
                            )
                        |> Maybe.withDefault ( Failure [ "email or password is invalid" ], Cmd.none )
            in
            ( model, Cmd.batch [ send_ (PageMsg (Gen.Msg.Login (Pages.Login.GotUser response))), cmd ] )

        UserRegistration_Register { params } ->
            let
                ( model_, cmd, res ) =
                    if model.users |> Dict.any (\k u -> u.email == params.email) then
                        ( model, Cmd.none, Failure [ "email address already taken" ] )

                    else
                        let
                            user_ =
                                { id = Dict.size model.users
                                , email = params.email
                                , username = params.username
                                , bio = Nothing
                                , image = "https://static.productionready.io/images/smiley-cyrus.jpg"
                                , password = params.password
                                , following = []
                                }
                        in
                        ( { model | users = model.users |> Dict.insert user_.id user_ }
                        , renewSession user_.id sessionId clientId
                        , Success (Api.User.toUser user_)
                        )
            in
            ( model_, Cmd.batch [ cmd, send_ (PageMsg (Gen.Msg.Register (Pages.Register.GotUser res))) ] )

        UserUpdate_Settings { params } ->
            let
                ( model_, res ) =
                    case model |> getSessionUser sessionId of
                        Just user ->
                            let
                                user_ =
                                    { user
                                        | username = params.username

                                        -- , email = params.email
                                        , password = params.password |> Maybe.withDefault user.password
                                        , image = params.image
                                        , bio = Just params.bio
                                    }
                            in
                            ( model |> updateUser user_, Success (Api.User.toUser user_) )

                        Nothing ->
                            ( model, Failure [ "you do not have permission for this user" ] )
            in
            ( model_, send_ (PageMsg (Gen.Msg.Settings (Pages.Settings.GotUser res))) )

        NoOpToBackend ->
            ( model, Cmd.none )


getSessionUser : SessionId -> Model -> Maybe UserFull
getSessionUser sid model =
    model.sessions
        |> Dict.get sid
        |> Maybe.andThen (\session -> model.users |> Dict.get session.userId)


renewSession email sid cid =
    Time.now |> Task.perform (RenewSession email sid cid)


uniqueSlug : Model -> String -> Int -> String
uniqueSlug model title i =
    title |> String.replace " " "-"


followUser : SessionId -> Email -> Model -> (Data (List String) Profile -> Cmd msg) -> ( Model, Cmd msg )
followUser sessionId email model toResponseCmd =
    let
        res =
            profileByEmail email model
                |> Maybe.map (\a -> Success { a | following = True })
                |> Maybe.withDefault (Failure [ "invalid user" ])
    in
    case model |> getSessionUser sessionId of
        Just user ->
            ( case model.users |> Dict.find (\l u -> u.email == email) of
                Just ( _, follow ) ->
                    model |> updateUser { user | following = (follow.id :: user.following) |> List.unique }

                Nothing ->
                    model
            , toResponseCmd res
            )

        Nothing ->
            ( model, toResponseCmd <| Failure [ "invalid session" ] )


unfollowUser : SessionId -> Email -> Model -> (Data (List String) Profile -> Cmd msg) -> ( Model, Cmd msg )
unfollowUser sessionId email model toResponseCmd =
    case model.users |> Dict.find (\k u -> u.email == email) of
        Just ( _, followed ) ->
            let
                res =
                    followed
                        |> Api.User.toProfile
                        |> (\a -> Success { a | following = False })
            in
            case model |> getSessionUser sessionId of
                Just user ->
                    ( model |> updateUser { user | following = user.following |> List.remove followed.id }
                    , toResponseCmd res
                    )

                Nothing ->
                    ( model, toResponseCmd <| Failure [ "invalid session" ] )

        Nothing ->
            ( model, toResponseCmd <| Failure [ "invalid user" ] )


updateUser : UserFull -> Model -> Model
updateUser user model =
    { model | users = model.users |> Dict.update user.id (Maybe.map (always user)) }


profileByUsername username model =
    model.users |> Dict.find (\k u -> u.username == username) |> Maybe.map (Tuple.second >> Api.User.toProfile)


profileByEmail email model =
    model.users |> Dict.find (\k u -> u.email == email) |> Maybe.map (Tuple.second >> Api.User.toProfile)
