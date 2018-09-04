defmodule FooWeb.CMS.PageView do
  use FooWeb, :view
  alias Foo.CMS

  def author_name(%CMS.Page{author: author}) do
     author.user.name
  end
end
