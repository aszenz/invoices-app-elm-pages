module Route.Invoices.Id_ exposing (Model, Msg, RouteParams, route, Data, ActionData)

{-|

@docs Model, Msg, RouteParams, route, Data, ActionData

-}

import BackendTask
import Data.Invoice
import Date
import Effect
import ErrorPage
import FatalError
import Form
import Form.Handler
import Form.Invoice
import Head
import Html
import Html.Attributes
import Html.Events.Extra
import List.Extra
import Pages.Form
import PagesMsg
import RouteBuilder
import Server.Request
import Server.Response
import Shared
import UrlPath
import View


type alias RouteParams =
    { id : String }


route : RouteBuilder.StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.serverRender { data = data, action = action, head = head }
        |> RouteBuilder.buildWithLocalState
            { view = view
            , init = init
            , update = update
            , subscriptions = subscriptions
            }


type alias Data =
    Data.Invoice.Invoice


type Action
    = EditedInvoice Data.Invoice.Invoice


type alias ActionData =
    Result (Form.ServerResponse String) ()


data :
    RouteParams
    -> Server.Request.Request
    -> BackendTask.BackendTask FatalError.FatalError (Server.Response.Response Data ErrorPage.ErrorPage)
data routeParams request =
    let
        _ =
            Debug.log "CALLED DATA" ""
    in
    BackendTask.succeed
        (Data.Invoice.exampleInvoices
            |> List.Extra.find (\invoice -> invoice.number == routeParams.id)
            |> Maybe.map Server.Response.render
            |> Maybe.withDefault (Server.Response.errorPage ErrorPage.NotFound)
        )


action :
    RouteParams
    -> Server.Request.Request
    -> BackendTask.BackendTask FatalError.FatalError (Server.Response.Response ActionData ErrorPage.ErrorPage)
action routeParams request =
    let
        _ =
            Debug.log "CALLED ACTION" ""
    in
    case Server.Request.method request of
        Server.Request.Post ->
            let
                _ =
                    Debug.log "Raw form data: " Server.Request.rawFormData
            in
            case request |> Server.Request.formData formHandlers of
                Nothing ->
                    BackendTask.fail (FatalError.fromString "Missing form data")

                Just ( formResponse, parsedForm ) ->
                    case parsedForm of
                        Form.Valid (EditedInvoice invoice) ->
                            let
                                _ =
                                    Debug.log "Parsed form data: " invoice
                            in
                            -- BackendTask.succeed (Server.Response.render (Ok ()))
                            BackendTask.succeed
                                (Server.Response.render (formResponse |> Err))

                        Form.Invalid _ invalidForm ->
                            BackendTask.succeed
                                (Server.Response.render (formResponse |> Err))

        _ ->
            Server.Response.plainText "Method  not supported"
                -- |> Server.Response.withStatusCode 400
                |> BackendTask.succeed


formHandlers : Form.Handler.Handler String Action
formHandlers =
    Form.Handler.init EditedInvoice Form.Invoice.invoiceForm


head : RouteBuilder.App Data ActionData RouteParams -> List Head.Tag
head app =
    []


view :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View.View (PagesMsg.PagesMsg Msg)
view app shared model =
    { title = "Invoice " ++ app.data.number
    , body =
        [ Html.h2 []
            [ Html.text ("Invoice " ++ model.invoice.number)
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

            Just (Ok _) ->
                Html.div []
                    [ Html.span [] [ Html.text "Changes saved" ]
                    , Pages.Form.renderHtml
                        []
                        (Form.options
                            "invoice"
                            |> Form.withInput (Just app.data)
                        )
                        app
                        Form.Invoice.invoiceForm
                    ]

            Just (Err formRes) ->
                Html.div []
                    [ Html.span [] [ Html.text "Errors while saving" ]
                    , Pages.Form.renderHtml
                        []
                        (Form.options
                            "invoice"
                            |> Form.withServerResponse (Just formRes)
                            |> Form.withInput Nothing
                        )
                        app
                        Form.Invoice.invoiceForm
                    ]
        ]
    }



-- FRONTEND


type alias Model =
    { invoice : Data.Invoice.Invoice
    }


type Msg
    = NoOp
    | AddInvoiceItem
    | RemoveInvoiceItem Int


init :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> ( Model, Effect.Effect Msg )
init app shared =
    ( { invoice = app.data }, Effect.none )


update :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Msg
    -> Model
    -> ( Model, Effect.Effect Msg )
update app shared msg ({ invoice } as model) =
    case msg of
        NoOp ->
            ( model, Effect.none )

        AddInvoiceItem ->
            ( { model
                | invoice =
                    { invoice
                        | items = List.append invoice.items [ { product = "", quantity = 0, price = 0.0 } ]
                    }
              }
            , Effect.none
            )

        RemoveInvoiceItem index ->
            ( { model
                | invoice =
                    { invoice
                        | items = List.Extra.removeAt index invoice.items
                    }
              }
            , Effect.none
            )


subscriptions : RouteParams -> UrlPath.UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions routeParams path shared model =
    Sub.none


invoiceFormView : Model -> Html.Html (PagesMsg.PagesMsg Msg)
invoiceFormView model =
    Html.form [ Html.Attributes.method "POST" ]
        [ Html.nav []
            [ Html.input [ Html.Attributes.type_ "submit", Html.Attributes.value "Save" ] []
            ]
        , Html.hr [] []
        , Html.div []
            [ Html.label
                [ Html.Attributes.style "display" "flex"
                , Html.Attributes.style "gap" "1rem"
                ]
                [ Html.text "Company"
                , Html.input
                    [ Html.Attributes.type_ "text"
                    , Html.Attributes.name "company"
                    , Html.Attributes.value model.invoice.company
                    ]
                    []
                ]
            , Html.label
                [ Html.Attributes.style "display" "flex"
                , Html.Attributes.style "gap" "1rem"
                ]
                [ Html.text "Date"
                , Html.input
                    [ Html.Attributes.type_ "date"
                    , Html.Attributes.name "date"
                    , Html.Attributes.value (Date.format "Y-m-d" model.invoice.date)
                    ]
                    []
                ]
            , Html.table []
                [ Html.thead []
                    [ Html.tr []
                        [ Html.th [] [ Html.text "Product" ]
                        , Html.th [] [ Html.text "Quantity" ]
                        , Html.th [] [ Html.text "Price" ]
                        , Html.th [] [ Html.text "Delete" ]
                        ]
                    ]
                , Html.tbody []
                    (model.invoice.items
                        |> List.indexedMap
                            (\index invoiceItem ->
                                Html.tr []
                                    [ Html.td [] [ Html.input [ Html.Attributes.type_ "text", Html.Attributes.value invoiceItem.product ] [] ]
                                    , Html.td [] [ Html.input [ Html.Attributes.type_ "number", invoiceItem.quantity |> String.fromInt |> Html.Attributes.value ] [] ]
                                    , Html.td [] [ Html.input [ Html.Attributes.type_ "number", invoiceItem.price |> String.fromFloat |> Html.Attributes.value ] [] ]
                                    , Html.td [] [ Html.button [ Html.Events.Extra.onClickPreventDefault (RemoveInvoiceItem index |> PagesMsg.fromMsg) ] [ Html.text "Remove" ] ]
                                    ]
                            )
                    )
                , Html.tfoot []
                    [ Html.button [ Html.Events.Extra.onClickPreventDefault (PagesMsg.fromMsg AddInvoiceItem) ] [ Html.text "Add invoice item" ]
                    ]
                ]
            ]
        ]
