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
import Dict
import ErrorPage
import FatalError
import Form
import Form.Handler
import Form.Invoice
import Form.Utils.FormGroup
import Form.Validation
import Head
import Html
import Pages.Form
import PagesMsg
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
    Data.Invoice.Invoice


type alias ActionData =
    { serverResponse : Form.ServerResponse String
    }


data :
    RouteParams
    -> Server.Request.Request
    -> BackendTask.BackendTask FatalError.FatalError (Server.Response.Response Data ErrorPage.ErrorPage)
data routeParams _ =
    let
        _ =
            Debug.log "CALLED DATA" ""
    in
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
    -> BackendTask.BackendTask FatalError.FatalError (Server.Response.Response ActionData ErrorPage.ErrorPage)
action routeParams request =
    case Server.Request.method request of
        Server.Request.Post ->
            case request |> Server.Request.formDataWithServerValidation formHandlers of
                Just bk ->
                    bk
                        |> BackendTask.andThen
                            (\result ->
                                case result of
                                    Ok ( formResponse, parsedForm ) ->
                                        Data.Invoice.updateInvoice { parsedForm | number = routeParams.id }
                                            |> BackendTask.allowFatal
                                            |> BackendTask.map
                                                (\_ -> Server.Response.render { serverResponse = formResponse })

                                    Err formResponse ->
                                        BackendTask.succeed
                                            (Server.Response.render { serverResponse = formResponse })
                            )

                Nothing ->
                    BackendTask.fail (FatalError.fromString "Missing form data")

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
        _ =
            Debug.log "data" app.data

        _ =
            Debug.log "action" app.action
    in
    { title = "Invoice " ++ app.data.number
    , body =
        [ Html.h2 []
            [ Html.text ("Invoice " ++ app.data.number)
            ]
        , case app.action of
            Nothing ->
                Pages.Form.renderHtml
                    []
                    (Form.options
                        "invoice"
                        |> Form.withInput (Just app.data)
                    )
                    app
                    Form.Invoice.invoiceForm

            Just { serverResponse } ->
                Html.div []
                    [ Html.span []
                        [ if Form.Utils.FormGroup.hasFormError serverResponse then
                            Html.text "Failed to save"

                          else
                            Html.text "Changes saved"
                        ]
                    , Pages.Form.renderHtml
                        []
                        (Form.options
                            "invoice"
                            |> Form.withInput (Just app.data)
                            |> Form.withServerResponse (Just serverResponse)
                        )
                        app
                        Form.Invoice.invoiceForm
                    ]
        ]
    }



-- formHandlers : Form.Handler.Handler String Action


formHandlers :
    Form.Handler.Handler
        String
        (BackendTask.BackendTask FatalError.FatalError (Form.Validation.Validation String Data.Invoice.Invoice Never Never))
formHandlers =
    Form.Handler.init Basics.identity Form.Invoice.invoiceForm


head : RouteBuilder.App Data ActionData RouteParams -> List Head.Tag
head _ =
    []



-- FRONTEND


type alias Model =
    {}


type alias Msg =
    ()
