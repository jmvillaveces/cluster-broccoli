module Main exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)
import Set exposing (Set)
import Models.Resources.Template exposing (..)
import Models.Resources.AboutInfo exposing (AboutInfo)
import Models.Resources.UserInfo exposing (UserInfo)
import Updates.UpdateAboutInfo exposing (updateAboutInfo)
import Updates.UpdateErrors exposing (updateErrors)
import Updates.UpdateLoginForm exposing (updateLoginForm)
import Updates.UpdateLoginStatus exposing (updateLoginStatus)
import Updates.Messages exposing (UpdateAboutInfoMsg(..), UpdateLoginStatusMsg(..), UpdateErrorsMsg(..))
import Commands.FetchAbout
import Messages exposing (AnyMsg(..))
import Models.Ui.Notifications exposing (Errors)
import Models.Ui.LoginForm exposing (LoginForm, emptyLoginForm)
import Views.Header
import Views.Body
import Views.Notifications
import WebSocket
import Dict

-- TODO what type of submessages do I want to have?
-- - Messages changing resources
-- - Error messages
-- - Messages changing the view
-- so one message per entry in my model? that means that not every single thing should define its own Msg type otherwise it will get crazy

type alias Model =
  { aboutInfo : Maybe AboutInfo
  -- , templates : List Template
  , errors : Errors
  , loginForm : LoginForm
  , loggedIn : Maybe UserInfo
  , authEnabled : Maybe Bool
  , templates : List Template
  -- , expandedNewInstanceForms : Set TemplateId
  }

initialModel : Model
initialModel =
  { aboutInfo = Nothing
  -- , templates = []
  , errors = []
  , loginForm = emptyLoginForm
  , loggedIn = Nothing
  , authEnabled = Nothing
  , templates =
    [ Template
        "curl"
        "This is a very curly template."
        "chj3kc67"
        [ "id"
        , "url"
        ]
        ( Dict.fromList
          [ ( "id", ParameterInfo "id" Nothing Nothing )
          , ( "url", ParameterInfo "url" (Just "http://localhost:8000") Nothing )
          ]
        )
    , Template
        "http-server"
        "Use this one to serve awesome HTTP responses based on a directory. The directory will be the one you are currently working in and it is a lot of fun to use this template."
        "dsadjda4"
        [ "id"
        , "password"
        ]
        ( Dict.fromList
          [ ( "id", ParameterInfo "id" Nothing Nothing )
          , ( "password", ParameterInfo "url" Nothing (Just True) )
          ]
        )
    ]
  -- , expandedNewInstanceForms = Set.empty
  }

init : ( Model, Cmd AnyMsg )
init =
  ( initialModel
  , Cmd.batch
    [ Cmd.map UpdateAboutInfoMsg Commands.FetchAbout.fetchAbout
    -- , Cmd.map FetchTemplatesMsg Commands.FetchTemplates.fetchTemplates
    ]
  )

update : AnyMsg -> Model -> ( Model, Cmd AnyMsg )
update msg model =
  case msg of
    -- FetchTemplatesMsg subMsg ->
      -- let (newTemplates, cmd) =
      --   updateTemplates subMsg model.templates
      -- in
      --   ({ model | templates = newTemplates }
      --   , cmd
      --   )
    UpdateAboutInfoMsg subMsg ->
      let ((newAbout, newAuthEnabled), cmd) =
        updateAboutInfo subMsg model.aboutInfo
      in
        ( { model
          | aboutInfo = newAbout
          , authEnabled = newAuthEnabled
          }
        , cmd
        )
    UpdateLoginStatusMsg subMsg ->
      let (newLoginStatus, cmd) =
        updateLoginStatus subMsg model.loggedIn
      in
        ({ model | loggedIn = newLoginStatus }
        , cmd
        )
    UpdateErrorsMsg subMsg ->
      let (newErrors, cmd) =
        updateErrors subMsg model.errors
      in
        ({ model | errors = newErrors }
        , cmd
        )
    UpdateLoginFormMsg subMsg ->
      let (newLoginForm, cmd) =
        updateLoginForm subMsg model.loginForm
      in
        ({ model | loginForm = newLoginForm }
        , cmd
        )
    NoOp -> (model, Cmd.none)

view : Model -> Html AnyMsg
view model =
  div
    []
    [ Views.Header.view model.aboutInfo model.loginForm model.loggedIn model.authEnabled
    , Views.Notifications.view model.errors
    , Views.Body.view model.templates
    , text (toString model)
    ]

subscriptions : Model -> Sub AnyMsg
subscriptions model =
  Sub.map
    UpdateErrorsMsg
    -- TODO I need a module to handle the websocket string messages and parse them into JSON somehow
    -- TODO cut the websocket connection on logout
    ( WebSocket.listen "ws://localhost:9000/ws" AddError )

main =
  program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }