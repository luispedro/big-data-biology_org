module Page.Index exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import DataSource.File
import Head
import Head.Seo as Seo
import Page exposing (Page, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Shared
import View exposing (View)
import SiteMarkdown


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    {}

type alias Data = String

page : Page RouteParams Data
page =
    Page.single
        { head = head
        , data = data
        }
        |> Page.buildNoState { view = view }


data : DataSource Data
data = DataSource.File.bodyWithoutFrontmatter "content/index.md"


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "Big Data Biology Lab (BDB-Lab)"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "Website of the BDB-Lab (run by Luis Pedro Coelho) at Fudan University"
        , locale = Nothing
        , title = "Big Data Biology Lab"
        }
        |> Seo.website




view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
        { title = "BDB-Lab"
        , body = [SiteMarkdown.mdToHtml static.data]
        , sidebar = Nothing
        }
