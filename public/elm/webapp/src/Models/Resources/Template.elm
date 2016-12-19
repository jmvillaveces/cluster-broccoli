module Models.Resources.Template exposing (..)

import Json.Decode as Decode exposing (field)
import Utils.DecodeUtils as DecodeUtils
import Dict exposing (Dict)

type alias TemplateId = String

type alias Template =
  { id : TemplateId
  , description : String
  , version : String
  , parameters : List String
  , parameterInfos : Dict String ParameterInfo
  }

type alias ParameterInfo =
  { name : String
  , default : Maybe String
  , secret : Maybe Bool
  }

addTemplateInstanceString template =
    String.concat ["New ", template.id, " instance"]

decoder =
  Decode.map5 Template
    (field "id" Decode.string)
    (field "description" Decode.string)
    (field "version" Decode.string)
    (field "parameters" (Decode.list Decode.string))
    (field "parameterInfos" (Decode.dict parameterInfoDecoder))

parameterInfoDecoder =
  Decode.map3 ParameterInfo
    (field "name" Decode.string)
    (field "default" (DecodeUtils.maybe Decode.string))
    (field "secret" (DecodeUtils.maybe Decode.bool))
