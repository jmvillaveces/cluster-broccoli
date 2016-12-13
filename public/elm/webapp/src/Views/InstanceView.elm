module Views.InstanceView exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Views.NewInstanceForm
import Dict exposing (..)
import Models.Resources.Instance exposing (..)
import Models.Resources.ServiceStatus exposing (..)
import Models.Resources.JobStatus exposing (..)
import Models.Resources.Template exposing (TemplateId, Template, addTemplateInstanceString)
import Set exposing (Set)
import Maybe
import Views.NewInstanceForm exposing (view)
import Updates.Messages exposing (UpdateBodyViewMsg(..))
import Utils.HtmlUtils exposing (icon, iconButtonText, iconButton)

view services instances jobStatuses =
  table
    [ class "table table-hover"
    , style [ ("margin-bottom", "0px") ]
    ]
    [ thead []
      [ tr []
        [ th []
          [ input
            [ type_ "checkbox"
            , title "Select All"
            ]
            []
          ]
        , th []
          [ icon "fa fa-hashtag" [ title "Instance ID" ] ]
        , th [ class "text-center" ]
          [ icon "fa fa-code-fork" [ title "Template Version" ] ]
        , th [ class "text-center" ]
          [ icon "fa fa-cubes" [ title "Services" ] ]
        , th [ class "text-center" ]
          [ icon "fa fa-cogs" [ title "Job Controls" ] ]
        ]
      ]
    , tbody []
      ( List.map (instanceRow services jobStatuses) instances )
    ]

instanceRow services jobStatuses instance =
  let (maybeInstanceServices, jobStatus) =
    ( Dict.get instance.id services
    , Maybe.withDefault JobUnknown (Dict.get instance.id jobStatuses)
    )
  in
    tr []
      [ td []
        [ input [ type_ "checkbox" ] [] ]
      , td []
        [ span
            [ style [ ("role", "button") ] ]
            [ text instance.id ]
        ]
      , td [ class "text-center" ]
        [ span
          [ style [ ("font-family", "monospace") ] ]
          [ text (String.left 8 instance.template.version) ]
        ]
      , td [ class "text-center" ]
        ( servicesView maybeInstanceServices )
      , td [ class "text-center" ]
        [ jobStatusView jobStatus
        , text " "
        , iconButton "btn btn-default btn-xs" "glyphicon glyphicon-play" "Start Instance"
        , text " "
        , iconButton "btn btn-default btn-xs" "glyphicon glyphicon-stop" "Stop Instance"
        ]
      ]

jobStatusView jobStatus =
  let (statusLabel, statusText) =
    case jobStatus of
      JobRunning -> ("success", "running")
      JobPending -> ("warning", "pending")
      JobStopped -> ("default", "stopped")
      JobDead    -> ("primary", "done")
      JobUnknown -> ("warning", "unknown")
  in
    span
      [ class ( String.concat [ "label label-", statusLabel ] )
      , style
        [ ("font-size", "90%")
        , ("width", "80px")
        , ("display", "inline-block")
        , ("margin-right", "8px")
        ]
      ]
      [ text statusText ]

servicesView maybeServices =
  case maybeServices of
    Just services ->
      (List.concatMap serviceView services)
    Nothing ->
      [ text "-" ]

serviceView service =
  let (iconClass, textColor) =
    case service.status of
      ServicePassing ->
        ("fa fa-check-circle", "#070")
      ServiceFailing ->
        ("fa fa-times-circle", "#900")
      ServiceUnknown ->
        ("fa fa-question-circle", "grey")
  in
    [ a
      [ href
        ( String.concat
          [ service.protocol
          , "://"
          , service.address
          , ":"
          , (toString service.port_)
          ]
        )
      , style
        [ ("margin-right", "8px")
        , ("color", textColor)
        ]
      ]
      [ icon iconClass [ style [ ("margin-right", "4px") ] ]
      , text service.name
      ]
    , text " "
    ]
