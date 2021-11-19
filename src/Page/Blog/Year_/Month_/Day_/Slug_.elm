module Page.Blog.Year_.Month_.Day_.Slug_ exposing (Model, Msg, Data, page)
import List.Extra exposing (find)

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

import Html
import Html.Events
import Html.Attributes as HtmlAttr

import SiteMarkdown
import Page.Blog exposing (BlogPost, posts)


type alias Model =
    ()


type alias Msg =
    Never

type alias RouteParams =
    { year : String, month : String, day : String, slug : String }

type alias Data = BlogPost

page : Page RouteParams Data
page =
    Page.prerender
        { head = head
        , routes = routes
        , data = data
        }
        |> Page.buildNoState { view = view }


toRoute p = { year = p.year, month = p.month, day = p.day, slug = p.slug }

routes : DataSource (List RouteParams)
routes =
    DataSource.map (List.map toRoute) posts



data : RouteParams -> DataSource Data
data routeParams =
    let
        findPage ms = case find (\p -> toRoute p == routeParams) ms of
            Just p -> DataSource.succeed p
            Nothing -> DataSource.fail "Could not find blog post"
    in posts |> DataSource.andThen findPage

head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "BDB-Lab Blog"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "BDB-Lab Blogpost: " ++ static.data.title
        , locale = Nothing
        , title = static.data.title
        }
        |> Seo.website


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
            { title = static.data.title
            , body =
                [Html.h1 [] [Html.text static.data.title]
                ,Html.div []
                    <| case static.data.authors of
                        Nothing -> []
                        Just ax -> [Html.p [HtmlAttr.style "padding-bottom" "1em"]
                                        [Html.text "by "
                                        ,Html.text ax
                                        ,Html.text "."]]
                ,SiteMarkdown.mdToHtml static.data.body]
            , sidebar = Nothing
            }

