module Shared exposing (Data, Model, Msg(..), SharedMsg(..), template)

import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row

import Browser.Navigation
import DataSource
import Html exposing (Html)
import Html.Attributes as HtmlAttr
import Pages.Flags
import Pages.PageUrl exposing (PageUrl)
import Path exposing (Path)
import Route exposing (Route)
import SharedTemplate exposing (SharedTemplate)
import View exposing (View)

import Lab.Lab as Lab
import Lab.BDBLab as BDBLab

template : SharedTemplate Msg Model Data msg
template =
    { init = init
    , update = update
    , view = view
    , data = data
    , subscriptions = subscriptions
    , onPageChange = Just OnPageChange
    }


type Msg
    = OnPageChange
        { path : Path
        , query : Maybe String
        , fragment : Maybe String
        }
    | SharedMsg SharedMsg


type alias Data = List Lab.Member


type SharedMsg
    = NoOp


type alias Model =
    { showMobileMenu : Bool
    }


init :
    Maybe Browser.Navigation.Key
    -> Pages.Flags.Flags
    ->
        Maybe
            { path :
                { path : Path
                , query : Maybe String
                , fragment : Maybe String
                }
            , metadata : route
            , pageUrl : Maybe PageUrl
            }
    -> ( Model, Cmd Msg )
init navigationKey flags maybePagePath =
    ( { showMobileMenu = False }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnPageChange _ ->
            ( { model | showMobileMenu = False }, Cmd.none )

        SharedMsg globalMsg ->
            ( model, Cmd.none )


subscriptions : Path -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none


data : DataSource.DataSource Data
data = BDBLab.members


view :
    Data
    ->
        { path : Path
        , route : Maybe Route
        }
    -> Model
    -> (Msg -> msg)
    -> View msg
    -> { body : Html msg, title : String }
view sharedData page model toMsg pageView =
    { body = Html.div []
        [ CDN.stylesheet
        , CDN.fontAwesome
        , Grid.containerFluid []
            [ Grid.simpleRow
                [ Grid.col []
                    [ Html.div [HtmlAttr.style "padding-top" "1em"] []
                    , header
                    , Grid.simpleRow
                        [ Grid.col [Col.sm3, Col.attrs [HtmlAttr.id "leftbar"]]
                            (case pageView.sidebar of
                                Just p -> [p]
                                Nothing ->
                                    [Html.h3 [] [Html.text "Most recent paper"]
                                    ,Html.div
                                        [HtmlAttr.style "border-left" "2px solid #333"
                                        ,HtmlAttr.style "padding-left" "0.5em"
                                        ,HtmlAttr.style "margin" "1em"
                                        ]

                                        [Html.p []
                                            [Html.a [HtmlAttr.href "https://doi.org/10.1101/2021.08.16.456517"]
                                                [Html.text "SemiBin: Incorporating information from reference genomes with semi-supervised deep learning leads to better metagenomic assembled genomes (MAGs)"]
                                            ,Html.text " by Shaojun Pan "
                                            ,Html.i [] [Html.text "et al"]
                                            ,Html.text ". at "
                                            ,Html.i [] [Html.text "bioRxiv (2021)"]
                                            ]
                                        ]
                                    ,Html.h3 [HtmlAttr.style "padding-top" "2em"] [Html.text "Updates"]
                                    ,Html.p []
                                        [Html.a [HtmlAttr.href "https://bigdatabiology.substack.com/"] [Html.text "Quarterly update newsletter"]]
                                    ,Html.p []
                                        [Html.a [HtmlAttr.href "posts/"] [Html.text "Big Data Biology Lab's Blog"]]
                                    ,Html.p []
                                        [Html.a [HtmlAttr.href "https://twitter.com/BigDataBiology"] [Html.text "@BigDataBiology on Twitter"]]
                                    ,Html.h3 [HtmlAttr.style "padding-top" "2em"] [Html.text "Lab Members"]
                                    ,showMembers sharedData
                                    ,Html.div [HtmlAttr.style "padding-top" "2em"]
                                        [Html.h3 [] [Html.text "Twitter feed"]
                                        ,Html.a
                                            [HtmlAttr.class "twitter-timeline"
                                            ,HtmlAttr.id "twitter-timeline-a"
                                            ,HtmlAttr.attribute "data-width" "240"
                                            ,HtmlAttr.attribute "data-height" "480"
                                            ,HtmlAttr.href "https://twitter.com/BigDataBiology?ref_src=twsrc%5Etfw"

                                            ]
                                            [Html.text "Tweets by BigDataBiology"]
                                        ,Html.div [HtmlAttr.id "twitter-injection-site"]
                                            []
                                        ]
                                    ])
                        , Grid.col [Col.xs9]
                            [Html.div [] pageView.body]
                        ]
                    , Html.hr [] []
                    , footer
                    ]
                ]
            ]
        ]
    , title = pageView.title
    }

showMembers members =
    Html.div []
        (List.map (\m
                    -> Html.p []
                        [Html.a [HtmlAttr.href ("/person/"++m.slug)] [Html.text m.name]])
            members)

header =
    let
        link target name =
            Grid.col []
                [Html.a [HtmlAttr.href target] [Html.text name]]
    in Html.div
        [HtmlAttr.id "topbar"]
        [Grid.simpleRow
            [ link "/index" "Home"
            , link "/people/" "Members"
            , link "/papers/" "Papers"
            , link "/blog/" "Blog"
            , link "/positions/" "Open Positions"
            , link "/faq/" "FAQ"
            ]]
footer = Html.div []
            [Html.p []
                [Html.text "Copyright (c) 2018-2021. Luis Pedro Coelho and other group members. All rights reserved."]
            ]
