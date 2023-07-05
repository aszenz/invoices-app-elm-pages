module Form.Utils.FormGroup exposing (errorsView, fieldView, hasFormError)

import Dict
import Form
import Form.FieldView
import Form.Validation
import Html
import Html.Attributes


fieldView :
    String
    -> Form.Validation.Field String parsed Form.FieldView.Input
    -> List (Html.Attribute msg)
    -> Form.Context String input
    -> Html.Html msg
fieldView label field attrs formState =
    Html.div []
        [ Html.label []
            [ Html.span [] [ Html.text (label ++ " ") ]
            , Form.FieldView.input attrs field
            , errorsView formState field
            ]
        ]


errorsView :
    Form.Context String input
    -> Form.Validation.Field String parsed kind
    -> Html.Html msg
errorsView { submitAttempted, errors } field =
    if submitAttempted then
        --     -- only show Form.Validations when a field has been blurred
        --     -- (it can be annoying to see errors while you type the initial entry for a field, but we want to see the current
        --     -- errors once we've left the field, even if we are changing it so we know once it's been fixed or whether a new
        --     -- error is introduced)
        errors
            |> Form.errorsForField field
            |> List.map (\error -> Html.li [ Html.Attributes.style "color" "red" ] [ Html.text error ])
            |> Html.ul []

    else
        Html.ul [] []


hasFormError : Form.ServerResponse a -> Bool
hasFormError { serverSideErrors, persisted } =
    (Dict.isEmpty serverSideErrors
        && (Maybe.map Dict.isEmpty persisted.clientSideErrors
                |> Maybe.withDefault True
           )
    )
        |> Basics.not
