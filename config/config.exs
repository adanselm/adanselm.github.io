import Config

config :tableau, :config,
  url: "http://localhost:4999",
  markdown: [
      mdex: [
        extension: [table: true, header_ids: "", tasklist: true, strikethrough: true],
        render: [unsafe_: true],
        features: [syntax_highlight_theme: "kanagawa"]
      ]
    ]

config :tableau, Tableau.PostExtension,
  enabled: true,
  future: true,
  layout: "Adanselm.PostLayout",
  permalink: "/blog/:year-:month-:day-:title"

config :tableau, :reloader,
  patterns: [
    ~r"lib/layouts/.*.ex",
    ~r"lib/pages/.*.ex",
    ~r"lib/components.ex",
    ~r"_site/.*.css"
  ]

config :tailwind,
  version: "3.3.5",
  default: [
    args: ~w(
    --config=tailwind.config.js
    --input=css/app.css
    --output=../_site/css/site.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :tableau, :assets, tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}

import_config "#{Mix.env()}.exs"
