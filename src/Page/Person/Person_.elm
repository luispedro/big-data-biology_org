module Page.Person.Person_ exposing (..)

import Html.Extra
import List.Extra
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import FeatherIcons

import DataSource exposing (DataSource)
import Head
import Head.Seo as Seo
import Page exposing (Page, PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Shared
import View exposing (View)
import DataSource.File
import OptimizedDecoder as Decode exposing (Decoder)


import Html exposing (Html)
import Html.Attributes as HtmlAttr
import Html.Events

import SiteMarkdown exposing (mdToHtml)
import Lab.Utils exposing (showAuthors)
import Lab.Lab as Lab
import Lab.BDBLab as BDBLab

type alias Data = (List Lab.Member, Lab.Member)
type alias RouteParams = { person : String }
type alias Model =
    { activePub : Maybe Int
    , activeProject : Maybe Int
    }
type Msg =
        ActivatePub Int
        | ActivateProject Int
        | DeactivatePub
        | NoOp

head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-pages"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "TODO"
        , locale = Nothing
        , title = "TODO title" -- metadata.title -- TODO
        }
        |> Seo.website

init : () -> ( Model, Cmd Msg )
init () =
    ( { activePub = Nothing
      , activeProject = Nothing
      }
    , Cmd.none
    )

page = Page.prerender
        { head = head
        , routes = routes
        , data = \routeParams ->
                BDBLab.membersAndAlumni
                    |> DataSource.andThen ( \ms ->
                        case List.Extra.find (\m -> toRoute m == routeParams) ms of
                            Just p -> DataSource.succeed (ms, p)
                            Nothing -> DataSource.fail "Internal error. Cannot find person??")
        }
        |> Page.buildWithLocalState
            { view = view
            , init = \_ _ staticPayload -> init ()
            , update = \_ _ _ _ -> update
            , subscriptions = \_ _ _ _-> Sub.none
            }

toRoute : Lab.Member -> RouteParams
toRoute m = { person = m.slug }

routes : DataSource (List RouteParams)
routes = DataSource.map (List.map toRoute) BDBLab.membersAndAlumni

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = case msg of
    ActivatePub ix -> ( {model | activePub = Just ix}, Cmd.none )
    ActivateProject ix -> ( {model | activeProject = Just ix}, Cmd.none )
    _ -> (model, Cmd.none)

view :
    Maybe PageUrl
    -> Shared.Model
    -> Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl shared model data =
    { title = (Tuple.second data.data).name
    , body = [showMember data.data model]
    , sidebar = Nothing
    }

maybeLink base ell t = case ell of
        Just u -> [Html.a [HtmlAttr.href (base++u)
                          ,HtmlAttr.style "padding-right" "3px"] [FeatherIcons.toHtml [] t]]
        Nothing -> []

showMember (members, m) model =
    Grid.simpleRow
        [Grid.col []
            [Html.h4 [] [Html.text m.name]
            ,mdToHtml m.long_bio
            ,Html.Extra.viewIf
                (not <| List.isEmpty m.projects)
                <| Html.div []
                    [Html.h4 [] [Html.text "BDB-Lab Projects"]
                    ,Html.ol
                        []
                        (List.indexedMap (showProject members model) m.projects)
                    ]
            ,Html.Extra.viewIf
                (not <| List.isEmpty m.papers)
                <| Html.div []
                [Html.h4 [] [Html.text "BDB-Lab Publications"]
                ,Html.ol
                    []
                    (List.indexedMap (showPub members model) m.papers)
                ]
            ,case m.gscholar of
                Just g ->
                        Html.p []
                            [Html.a
                                [HtmlAttr.href ("https://scholar.google.com/citations?hl=en&user="++g)]
                                [Html.text "Full list of publications on Google Scholar..."]]
                Nothing -> Html.text ""
            ]
        ,Grid.col
            [Col.xs4]
            [Html.img [HtmlAttr.src ("/images/people/"++m.slug++".jpeg")
                    , HtmlAttr.style "max-height" "240px"
                    , HtmlAttr.style "border-radius" "50%"
                    ]
                []
            ,Html.div
                [HtmlAttr.style "padding-left" "40px"
                ,HtmlAttr.style "padding-top" "1em"
                ]
                [Html.p [] (List.concat
                    [ maybeLink "mailto:" m.email FeatherIcons.mail
                    , maybeLink "https://github.com/" m.github FeatherIcons.github
                    , maybeLink "https://twitter.com/" m.twitter FeatherIcons.twitter
                    , maybeLink "https://orcid.org/" m.orcid FeatherIcons.circle
                    , maybeLink "https://scholar.google.com/citations?hl=en&user=" m.gscholar FeatherIcons.rss
                    ])
                ]
            ]
        ]

showPub : List Lab.Member -> Model -> Int -> Lab.Publication -> Html Msg
showPub members model ix pub =
    Html.li [] <|
        if model.activePub == Just ix
            then [Html.div []
                [Html.p []
                    ([Html.strong [] [Html.text pub.title]
                    ,Html.br [] []
                    ,Html.text ("by ")] ++ (showAuthors pub.authors members))
                ,Html.div
                    [HtmlAttr.style "float" "left"
                    ,HtmlAttr.style "padding-right" "2em"
                    ]
                    [Html.img [HtmlAttr.src ("/images/papers/"++pub.slug++".png")
                                ,HtmlAttr.style "max-height" "120px"]
                                []]
                ,Html.p []
                    [ Html.text pub.short_description]
                    , Html.br [] []
                    , Html.a [HtmlAttr.href ("https://doi.org/"++pub.doi)]
                            [Html.text "Full text.."]
                ,Html.div
                    [HtmlAttr.style "clear" "both"]
                    []
                ]]
            else
                [Html.a [HtmlAttr.href "#", Html.Events.onClick (ActivatePub ix)] [Html.text pub.title]]

showProject : List Lab.Member -> Model -> Int -> Lab.Project -> Html Msg
showProject members model ix proj =
    Html.li [] <|
        if model.activeProject == Just ix
            then [Html.div []
                [Html.p []
                    [Html.strong [] [Html.text proj.title]
                    ,Html.br [] []
                    ]
                ,Html.p []
                    [ Html.text proj.short_description]
                    , Html.br [] []
                    ]
                ,Html.p []
                    [ Html.a
                        [HtmlAttr.href ("/project/"++proj.slug)]
                        [Html.text "Learn more about project "
                        ,Html.i [] [Html.text proj.title]
                        ,Html.text "..."]
                    ]
                ]
            else
                [Html.a [HtmlAttr.href "#", Html.Events.onClick (ActivateProject ix)] [Html.text proj.title]]
