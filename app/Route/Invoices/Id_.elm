module Route.Invoices.Id_ exposing
    ( ActionData
    , Data
    , Model
    , Msg
    , RouteParams
    , route
    )

import BackendTask
import Data.Invoice
import ErrorPage
import FatalError
import Form
import Form.Handler
import Form.Invoice
import Form.Utils.FormGroup
import Form.Validation
import Head
import Html
import Html.Attributes
import Pages.Form
import PagesMsg
import Route
import RouteBuilder
import Server.Request
import Server.Response
import Shared
import View


route : RouteBuilder.StatefulRoute RouteParams Data ActionData {} ()
route =
    RouteBuilder.serverRender
        { data = data
        , action = action
        , head = head
        }
        |> RouteBuilder.buildNoState
            { view = view
            }


type alias RouteParams =
    { id : String }


type alias Data =
    Data.Invoice.SavedInvoice


type Action
    = SaveInvoice (BackendTask.BackendTask FatalError.FatalError (Form.Validation.Validation String Data.Invoice.FormInvoice Never Never))
    | DeleteInvoice ()


type alias ActionData =
    { serverFormResponse : Form.ServerResponse String
    }


data :
    RouteParams
    -> Server.Request.Request
    -> BackendTask.BackendTask FatalError.FatalError (Server.Response.Response Data ErrorPage.ErrorPage)
data routeParams _ =
    Data.Invoice.getInvoice routeParams.id
        |> BackendTask.allowFatal
        |> BackendTask.map
            (\invoice ->
                case invoice of
                    Just inv ->
                        Server.Response.render inv

                    Nothing ->
                        Server.Response.errorPage ErrorPage.NotFound
            )


action :
    RouteParams
    -> Server.Request.Request
    -> BackendTask.BackendTask FatalError.FatalError (Server.Response.Response ActionData error)
action routeParams request =
    case Server.Request.method request of
        Server.Request.Post ->
            routeParams.id
                |> Data.Invoice.getInvoice
                |> BackendTask.allowFatal
                |> BackendTask.andThen
                    (\originalInvoice ->
                        case Server.Request.formData (formHandlers originalInvoice) request of
                            Just ( serverResponse, Form.Valid (SaveInvoice backendTask) ) ->
                                backendTask
                                    |> BackendTask.andThen
                                        (\output ->
                                            case Form.Validation.value output of
                                                Just inv ->
                                                    Data.Invoice.updateInvoice
                                                        { id = routeParams.id
                                                        , number = inv.number
                                                        , company = inv.company
                                                        , date = inv.date
                                                        , items = []
                                                        }
                                                        |> BackendTask.allowFatal
                                                        |> BackendTask.map
                                                            (\_ -> Route.redirectTo (Route.Invoices__Id_ { id = routeParams.id }))

                                                Nothing ->
                                                    BackendTask.succeed
                                                        (Server.Response.render { serverFormResponse = serverResponse })
                                        )

                            Just ( _, Form.Valid (DeleteInvoice _) ) ->
                                Data.Invoice.deleteInvoice routeParams.id
                                    |> BackendTask.allowFatal
                                    |> BackendTask.map
                                        (\_ -> Route.redirectTo Route.Invoices)

                            Just ( serverResponse, Form.Invalid _ _ ) ->
                                BackendTask.succeed
                                    (Server.Response.render { serverFormResponse = serverResponse })

                            Nothing ->
                                BackendTask.fail (FatalError.fromString "Missing form data")
                    )

        _ ->
            Server.Response.plainText "Method  not supported"
                -- |> Server.Response.withStatusCode 400
                |> BackendTask.succeed


view :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> View.View (PagesMsg.PagesMsg Msg)
view app _ =
    let
        updateInvoiceFormId =
            "update-invoice-" ++ app.data.id

        deleteInvoiceFormId =
            "delete-invoice-" ++ app.data.id
    in
    { title = "Invoice " ++ app.data.number
    , body =
        [ Html.h2 []
            [ Html.text ("Invoice " ++ app.data.number)
            , Html.text (", Company " ++ app.data.company)
            ]
        , Html.nav []
            [ if Form.Utils.FormGroup.isFormSubmitting updateInvoiceFormId app then
                Html.button [ Html.Attributes.disabled True ] [ Html.text "Saving invoice..." ]

              else
                Html.button [ Html.Attributes.type_ "submit", Html.Attributes.form updateInvoiceFormId ] [ Html.text "Save" ]
            , if Form.Utils.FormGroup.isFormSubmitting deleteInvoiceFormId app then
                Html.button [ Html.Attributes.disabled True ] [ Html.text "Deleting invoice..." ]

              else
                Html.button [ Html.Attributes.type_ "submit", Html.Attributes.form deleteInvoiceFormId ] [ Html.text "Delete" ]
            ]
        , case app.action of
            Nothing ->
                Html.div []
                    [ app.data
                        |> Just
                        |> Form.Invoice.invoiceForm
                        |> Pages.Form.renderHtml [] (Form.options updateInvoiceFormId |> Form.withInput (Just app.data)) app
                    , Form.Invoice.deleteInvoiceForm
                        |> Pages.Form.renderHtml [] (Form.options deleteInvoiceFormId) app
                    ]

            Just _ ->
                Html.div []
                    [ Html.span []
                        [ Html.text "Failed to save"
                        ]
                    , Form.Invoice.invoiceForm (Just app.data)
                        |> Pages.Form.renderHtml []
                            (Form.options updateInvoiceFormId
                                -- |> Form.withServerResponse (Just serverFormResponse)
                                |> Form.withInput (Just app.data)
                            )
                            app
                    , Form.Invoice.deleteInvoiceForm
                        |> Pages.Form.renderHtml [] (Form.options deleteInvoiceFormId) app
                    ]
        ]
    }


formHandlers : Maybe Data.Invoice.SavedInvoice -> Form.Handler.Handler String Action
formHandlers initialFormValue =
    Form.Handler.init SaveInvoice (Form.Invoice.invoiceForm initialFormValue)
        |> Form.Handler.with DeleteInvoice Form.Invoice.deleteInvoiceForm


head : RouteBuilder.App Data ActionData RouteParams -> List Head.Tag
head _ =
    []



-- FRONTEND


type alias Model =
    {}


type alias Msg =
    ()
