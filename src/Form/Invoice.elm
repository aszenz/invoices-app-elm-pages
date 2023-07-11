module Form.Invoice exposing (deleteInvoiceForm, invoiceForm)

import BackendTask
import Data.Invoice
import Form
import Form.Field
import Form.Utils.FormGroup
import Form.Validation
import Html
import Pages.Form


invoiceForm :
    Maybe Data.Invoice.ExistingInvoice
    ->
        Pages.Form.FormWithServerValidations
            String
            Data.Invoice.NewInvoice
            ()
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
                |> (case initialValue of
                        Just i ->
                            Form.Field.withInitialValue (i.number |> Basics.always)

                        Nothing ->
                            Basics.identity
                   )
            )
        |> Form.field "company"
            (Form.Field.text
                |> Form.Field.required "Required"
                |> (case initialValue of
                        Just i ->
                            Form.Field.withInitialValue (i.company |> Basics.always)

                        Nothing ->
                            Basics.identity
                   )
            )
        |> Form.field "date"
            (Form.Field.date { invalid = \_ -> "Bad value" }
                |> Form.Field.required "Required"
                |> (case initialValue of
                        Just i ->
                            Form.Field.withInitialValue (i.date |> Basics.always)

                        Nothing ->
                            Basics.identity
                   )
            )
        |> Form.hiddenKind ( "kind", "invoice" ) "Expected kind"


deleteInvoiceForm : Form.HtmlForm String () data msg
deleteInvoiceForm =
    { combine = Form.Validation.succeed ()
    , view = \_ -> []
    }
        |> Form.form
        |> Form.hiddenKind ( "kind", "deleteInvoice" ) "Expected kind"
