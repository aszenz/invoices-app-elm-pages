module Form.Invoice exposing (deleteInvoiceForm, invoiceForm, searchInvoicesForm)

import BackendTask
import Data.Invoice
import Form
import Form.Field
import Form.FieldView
import Form.Utils.FormGroup
import Form.Validation
import Html
import Pages.Form


invoiceForm :
    Maybe Data.Invoice.SavedInvoice
    ->
        Pages.Form.FormWithServerValidations
            String
            Data.Invoice.FormInvoice
            (Maybe Data.Invoice.SavedInvoice)
            (List (Html.Html msg))
invoiceForm initialValue =
    (\number company date ->
        { combine =
            Form.Validation.succeed
                (\numberValue companyValue dateValue ->
                    case initialValue of
                        Nothing ->
                            Data.Invoice.invoiceNoExists numberValue
                                |> BackendTask.allowFatal
                                |> BackendTask.map
                                    (\exists ->
                                        if exists then
                                            Form.Validation.fail
                                                ("Invoice no " ++ numberValue ++ " already exists")
                                                number

                                        else
                                            Form.Validation.succeed
                                                { number = numberValue
                                                , company = companyValue
                                                , date = dateValue
                                                , items = []
                                                }
                                    )

                        Just invoice ->
                            if invoice.number == numberValue then
                                { number = numberValue
                                , company = companyValue
                                , date = dateValue
                                , items = []
                                }
                                    |> Form.Validation.succeed
                                    |> BackendTask.succeed

                            else
                                Data.Invoice.invoiceNoExists numberValue
                                    |> BackendTask.allowFatal
                                    |> BackendTask.map
                                        (\exists ->
                                            if exists then
                                                Form.Validation.fail
                                                    ("Invoice no " ++ numberValue ++ " already exists")
                                                    number

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
                [ Form.Utils.FormGroup.errorsView formState Form.Validation.global
                , Html.fieldset []
                    [ Html.legend [] [ Html.text "Invoice" ]
                    , Form.Utils.FormGroup.fieldView "Number" number [] formState
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
                |> Form.Field.withOptionalInitialValue (\i -> Maybe.map .number i)
            )
        |> Form.field "company"
            (Form.Field.text
                |> Form.Field.required "Required"
                |> Form.Field.withOptionalInitialValue (\i -> Maybe.map .company i)
            )
        |> Form.field "date"
            (Form.Field.date { invalid = \_ -> "Bad value" }
                |> Form.Field.required "Required"
                |> Form.Field.withOptionalInitialValue (\i -> Maybe.map .date i)
            )
        |> Form.hiddenKind ( "kind", "invoice" ) "Expected kind"


deleteInvoiceForm : Form.HtmlForm String () data msg
deleteInvoiceForm =
    { combine = Form.Validation.succeed ()
    , view = \_ -> []
    }
        |> Form.form
        |> Form.hiddenKind ( "kind", "deleteInvoice" ) "Expected kind"


searchInvoicesForm viewWrapper =
    (\number company date ->
        { combine =
            Form.Validation.succeed
                (\numberVal companyVal dateVal ->
                    { number = numberVal
                    , company = companyVal
                    , date = dateVal
                    }
                )
                |> Form.Validation.andMap number
                |> Form.Validation.andMap company
                |> Form.Validation.andMap date
        , view =
            \formState ->
                viewWrapper
                    [ Html.div []
                        [ Html.text "Number"
                        , Form.FieldView.input [] number
                        ]
                    , Html.div []
                        [ Html.text "Company"
                        , Form.FieldView.input [] company
                        ]
                    , Html.div []
                        [ Html.text "Date"
                        , Form.FieldView.input [] date
                        ]
                    ]
        }
    )
        |> Form.form
        |> Form.field "number" Form.Field.text
        |> Form.field "company" Form.Field.text
        |> Form.field "date" (Form.Field.date { invalid = \_ -> "Bad value" })
