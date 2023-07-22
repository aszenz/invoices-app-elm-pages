module Route.Invoices.New exposing (ActionData, Data, Model, Msg, RouteParams, route)

import BackendTask
import Data.Invoice
import ErrorPage
import FatalError
import Form
import Form.Handler
import Form.Invoice
import Form.Validation
import Head
import Html
import Html.Attributes
import Pages.Form
import Pages.Navigation
import PagesMsg
import Route
import RouteBuilder
import Server.Request
import Server.Response
import Shared
import View


type alias RouteParams =
    {}


route : RouteBuilder.StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.serverRender { data = data, action = action, head = head }
        |> RouteBuilder.buildNoState
            { view = view
            }


type alias Data =
    {}


type alias ActionData =
    { serverFormResponse : Form.ServerResponse String
    }


data :
    RouteParams
    -> Server.Request.Request
    -> BackendTask.BackendTask FatalError.FatalError (Server.Response.Response Data ErrorPage.ErrorPage)
data _ _ =
    BackendTask.succeed (Server.Response.render {})


action :
    RouteParams
    -> Server.Request.Request
    -> BackendTask.BackendTask FatalError.FatalError (Server.Response.Response ActionData ErrorPage.ErrorPage)
action _ request =
    case Server.Request.method request of
        Server.Request.Post ->
            case Server.Request.formDataWithServerValidation formHandlers request of
                Just backendTask ->
                    backendTask
                        |> BackendTask.andThen
                            (\output ->
                                case output of
                                    Ok ( _, parsedForm ) ->
                                        Data.Invoice.createInvoice parsedForm
                                            |> BackendTask.allowFatal
                                            |> BackendTask.map
                                                (\invoice ->
                                                    Route.redirectTo (Route.Invoices__Id_ { id = invoice.id })
                                                )

                                    Err formErrorResponse ->
                                        BackendTask.succeed
                                            (Server.Response.render { serverFormResponse = formErrorResponse })
                            )

                Nothing ->
                    BackendTask.fail (FatalError.fromString "Missing form data")

        _ ->
            Server.Response.plainText "Method  not supported"
                -- |> Server.Response.withStatusCode 400
                |> BackendTask.succeed


formHandlers :
    Form.Handler.Handler
        String
        (BackendTask.BackendTask FatalError.FatalError (Form.Validation.Validation String Data.Invoice.FormInvoice Never Never))
formHandlers =
    Form.Invoice.invoiceForm Nothing
        |> Form.Handler.init Basics.identity


view :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> View.View (PagesMsg.PagesMsg Msg)
view app _ =
    { title = "Invoices.New"
    , body =
        [ Html.h2 []
            [ Html.text "New Invoice "
            ]
        , Html.nav []
            [ case app.navigation of
                Just (Pages.Navigation.Submitting _) ->
                    Html.button
                        [ Html.Attributes.disabled True ]
                        [ Html.text "Saving invoice..." ]

                _ ->
                    Html.button [ Html.Attributes.type_ "submit", Html.Attributes.form "invoice" ] [ Html.text "Save" ]
            ]
        , case app.action of
            Nothing ->
                Form.Invoice.invoiceForm Nothing
                    |> Pages.Form.renderHtml [] (Form.options "invoice" |> Form.withInput Nothing) app

            Just { serverFormResponse } ->
                Html.div []
                    [ Html.span []
                        [ Html.text "Failed to save"
                        ]
                    , Form.Invoice.invoiceForm Nothing
                        |> Pages.Form.renderHtml []
                            (Form.options "new-invoice"
                                |> Form.withServerResponse (Just serverFormResponse)
                                |> Form.withInput Nothing
                            )
                            app
                    ]
        ]
    }


head : RouteBuilder.App Data ActionData RouteParams -> List Head.Tag
head _ =
    []


type alias Model =
    {}


type alias Msg =
    ()
