defmodule Adanselm.RootLayout do
  use Tableau.Layout
  use Phoenix.Component

  def template(assigns) do
    ~H"""
    <!DOCTYPE HTML>
    <html>
      <head>
        <title>Adrien Anselme -- Personal page</title>
        <link rel="stylesheet" type="text/css" href="/css/site.css" />
        <link :if={assigns.page[:canonical]} rel="canonical" href={assigns.page[:canonical]} />
        <meta charset="utf-8" />

        <meta name="viewport" content="width=device-width, initial-scale=1.0" />

        <meta name="description" content="The personal page of software engineer Adrien Anselme" />

        <meta name="author" content="Adrien Anselme" />
        <meta property="og:locale" content="en_US" />
        <meta property="twitter:site" content="@adanselm" />
        <script defer data-domain="adrienanselme.com" src="https://plausible.aidrien.com/js/script.js"></script>
      </head>
      <body>
        <%= render(@inner_content) %>
      </body>
      <%= if Mix.env() == :dev do %>
        <Adanselm.live_reload />
      <% end %>
    </html>
    """
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
    |> HtmlEntities.decode()
  end
end
