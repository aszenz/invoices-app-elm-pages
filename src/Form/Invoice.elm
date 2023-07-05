module Form.Invoice exposing (invoiceForm)

import BackendTask
import Data.Invoice
import Form
import Form.Field
import Form.Utils.FormGroup
import Form.Validation
import Html
import Html.Attributes
import Pages.Form


invoiceForm :
    Pages.Form.FormWithServerValidations
        String
        Data.Invoice.Invoice
        (Maybe Data.Invoice.Invoice)
        (List (Html.Html msg))
invoiceForm =
    (\number company date ->
        { combine =
            Form.Validation.succeed
                (\numberValue companyValue dateValue ->
                    Data.Invoice.invoiceNoExists numberValue
                        |> BackendTask.allowFatal
                        |> BackendTask.map
                            (\exists ->
                                if exists then
                                    Form.Validation.fail "Invoice no already exists" number

                                else
                                    Form.Validation.succeed
                                        { number = numberValue
                                        , company = companyValue
                                        , date = dateValue
                                        , items = []
                                        }
                            )
                )
                |> Form.Validation.andMap number
                |> Form.Validation.andMap company
                |> Form.Validation.andMap date
        , view =
            \formState ->
                [ Html.nav []
                    [ if formState.submitting then
                        Html.button
                            [ Html.Attributes.disabled True ]
                            [ Html.text "Saving invoice..." ]

                      else
                        Html.button [] [ Html.text "Save" ]
                    ]
                , Form.Utils.FormGroup.errorsView formState Form.Validation.global
                , Html.fieldset []
                    [ Html.legend [] [ Html.text "Invoice" ]
                    , Form.Utils.FormGroup.fieldView "Number"
                        number
                        [ Html.Attributes.readonly
                            (case formState.input of
                                Just _ ->
                                    True

                                Nothing ->
                                    False
                            )
                        ]
                        formState
                    , Form.Utils.FormGroup.fieldView "Company" company [] formState
                    , Form.Utils.FormGroup.fieldView "Date" date [] formState
                    ]
                ]
        }
    )
        |> Form.form
        |> Form.field "number"
            (Form.Field.text
                |> Form.Field.required "Required"
                |> Form.Field.withOptionalInitialValue (Maybe.map .number)
            )
        |> Form.field "company"
            (Form.Field.text
                |> Form.Field.required "Required"
                |> Form.Field.withOptionalInitialValue (Maybe.map .company)
            )
        |> Form.field "date"
            (Form.Field.date { invalid = \_ -> "Bad value" }
                |> Form.Field.required "Required"
                |> Form.Field.withOptionalInitialValue (Maybe.map .date)
            )
