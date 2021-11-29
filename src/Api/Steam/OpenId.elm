module Api.Steam.OpenId exposing (getLoginUrl, parseResponseUrl)

import Api.Steam exposing (SteamId)
import Url exposing (Url)
import Url.Builder as Url
import Url.Parser as UrlParser exposing ((</>), (<?>), Parser, s)
import Url.Parser.Query as QueryParser
import Utils.Url exposing (domain)


getLoginUrl : Url -> String
getLoginUrl returnUrl =
    let
        string =
            Url.string
    in
    Url.crossOrigin "https://steamcommunity.com"
        [ "openid", "login" ]
        [ string "openid.mode" "checkid_setup"
        , string "openid.ns" "http://specs.openid.net/auth/2.0"
        , string "openid.ns.sreg" "http://openid.net/extensions/sreg/1.1"
        , string "openid.sreg.optional" "nickname,email,fullname,dob,gender,postcode,country,language,timezone"
        , string "openid.ns.ax" "http://openid.net/srv/ax/1.0"
        , string "openid.ax.mode" "fetch_request"
        , string "openid.ax.type.fullname" "http://axschema.org/namePerson"
        , string "openid.ax.type.firstname" "http://axschema.org/namePerson/first"
        , string "openid.ax.type.lastname" "http://axschema.org/namePerson/last"
        , string "openid.ax.type.email" "http://axschema.org/contact/email"
        , string "openid.ax.required" "fullname,firstname,lastname,email"
        , string "openid.identity" "http://specs.openid.net/auth/2.0/identifier_select"
        , string "openid.claimed_id" "http://specs.openid.net/auth/2.0/identifier_select"
        , string "openid.return_to" (Url.toString returnUrl)
        , string "openid.realm" (domain returnUrl |> Url.toString)
        ]


parseResponseUrl : Url -> Maybe SteamId
parseResponseUrl url =
    url
        |> UrlParser.parse identityParamParser
        |> Maybe.andThen Url.fromString
        |> Maybe.andThen (UrlParser.parse steamIdParser)


identityParamParser : Parser (String -> a) a
identityParamParser =
    UrlParser.query
        (QueryParser.string "openid.identity"
            |> QueryParser.map (Maybe.withDefault "")
        )


steamIdParser =
    let
        string =
            UrlParser.string
    in
    s "openid" </> s "id" </> string
