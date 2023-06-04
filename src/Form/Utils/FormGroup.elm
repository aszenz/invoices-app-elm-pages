module Form.Utils.FormGroup exposing (errorsView, fieldView)

import Form
import Form.FieldView
import Form.Validation
import Html
import Html.Attributes


fieldView :
    String
    -> Form.Validation.Field String parsed Form.FieldView.Input
    -> Form.Context String input
    -> Html.Html msg
fieldView label field formState =
    Html.div []
        [ Html.label []
            [ Html.span [] [ Html.text (label ++ " ") ]
            , Form.FieldView.input [] field
            , errorsView formState field
            ]
        ]


errorsView :
    Form.Context String input
    -> Form.Validation.Field String parsed kind
    -> Html.Html msg
errorsView { submitAttempted, errors } field =
    if submitAttempted || Form.Validation.statusAtLeast Form.Validation.Blurred field then
        -- only show Form.Validations when a field has been blurred
        -- (it can be annoying to see errors while you type the initial entry for a field, but we want to see the current
        -- errors once we've left the field, even if we are changing it so we know once it's been fixed or whether a new
        -- error is introduced)
        errors
            |> Form.errorsForField field
            |> List.map (\error -> Html.li [ Html.Attributes.style "color" "red" ] [ Html.text error ])
            |> Html.ul []

    else
        Html.ul [] []
