module Template exposing (Template(..), TodoListTemplate, TodoTemplate, getTodoByTemplateId, init)

import Dict exposing (Dict)


init =
    Template Dict.empty Dict.empty


type Template
    = Template (Dict String TodoListTemplate) (Dict String TodoTemplate)


type alias TodoListTemplate =
    { name : String }


type alias TodoTemplate =
    { name : String, templateId : String }


getTodoByTemplateId : String -> Dict String TodoTemplate -> Dict String TodoTemplate
getTodoByTemplateId id todoTemplates =
    Dict.filter (\_ value -> id == value.templateId) todoTemplates
