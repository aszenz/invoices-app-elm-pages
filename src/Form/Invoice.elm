module Form.Invoice exposing (..)

import Data.Invoice
import Form
import Form.Field
import Form.Utils.FormGroup
import Form.Validation
import Html
import Html.Attributes


invoiceForm : Form.HtmlForm String Data.Invoice.Invoice (Maybe Data.Invoice.Invoice) msg
invoiceForm =
    (\company date ->
        { combine =
            Form.Validation.succeed
                (\companyValue dateV ->
                    { number = ""
                    , company = companyValue
                    , date = dateV
                    , items = []
                    }
                )
                |> Form.Validation.andMap company
                |> Form.Validation.andMap date

        -- |> Form.Validation.andMap Form.Validation.global
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

                -- , Form.Utils.FormGroup.errorsView formState Form.Validation.global
                , Html.fieldset []
                    [ Html.legend [] [ Html.text "Invoice" ]
                    , Form.Utils.FormGroup.fieldView "Company" company formState
                    , Form.Utils.FormGroup.fieldView "Date" date formState
                    ]
                ]
        }
    )
        |> Form.form
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
