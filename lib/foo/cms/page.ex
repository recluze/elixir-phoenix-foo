defmodule Foo.CMS.Page do
  use Ecto.Schema
  import Ecto.Changeset

  alias Foo.CMS.Author

  schema "pages" do
    field :body, :string
    field :title, :string
    field :views, :integer
    belongs_to :author, Author

    timestamps()
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(attrs, [:title, :body, :views])
    |> validate_required([:title, :body, :views])
  end
end
