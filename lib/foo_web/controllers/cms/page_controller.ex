defmodule FooWeb.CMS.PageController do
  use FooWeb, :controller

  alias Foo.CMS
  alias Foo.CMS.Page

  plug :require_existing_author
  plug :authorize_page when action in [:edit, :update, :delete]



  def index(conn, _params) do
    pages = CMS.list_pages()
    render(conn, "index.html", pages: pages)
  end

  def new(conn, _params) do
    changeset = CMS.change_page(%Page{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"page" => page_params}) do
    case CMS.create_page(page_params) do
      {:ok, page} ->
        conn
        |> put_flash(:info, "Page created successfully.")
        |> redirect(to: cms_page_path(conn, :show, page))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    page = CMS.get_page!(id)
    render(conn, "show.html", page: page)
  end

  def edit(conn, %{"id" => id}) do
    page = CMS.get_page!(id)
    changeset = CMS.change_page(page)
    render(conn, "edit.html", page: page, changeset: changeset)
  end

  def update(conn, %{"id" => id, "page" => page_params}) do
    page = CMS.get_page!(id)

    case CMS.update_page(page, page_params) do
      {:ok, page} ->
        conn
        |> put_flash(:info, "Page updated successfully.")
        |> redirect(to: cms_page_path(conn, :show, page))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", page: page, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    page = CMS.get_page!(id)
    {:ok, _page} = CMS.delete_page(page)

    conn
    |> put_flash(:info, "Page deleted successfully.")
    |> redirect(to: cms_page_path(conn, :index))
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
