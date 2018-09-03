defmodule FooWeb.PageController do
  use FooWeb, :controller

  alias Foo.CMS

  plug :require_existing_author
  plug :authorize_page when action in [:edit, :update, :delete]


  def index(conn, _params) do
    render conn, "index.html"
  end

  defp require_existing_author(conn, _) do
    author = CMS.ensure_author_exists(conn.assigns.current_user)
    assign(conn, :current_author, author)
  end

  defp authorize_page(conn, _) do
    page = CMS.get_page!(conn.params["id"])

    if conn.assigns.current_author.id == page.author_id do
      assign(conn, :page, page)
    else
      conn
      |> put_flash(:error, "You can't modify that page")
      |> redirect(to: cms_page_path(conn, :index))
      |> halt()
    end
  end
end
