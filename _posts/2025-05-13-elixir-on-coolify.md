---
title:  "How I deployed an Elixir Phoenix project on a self-hosted Coolify server"
date:   "2025-05-13 21:27:00"
categories: programming elixir coolify
permalink: "/blog/:year-:month-:day-elixir-on-coolify"
thumbnail: "/images/coolify.jpg"
---

I the past few days I played around with using an LLM in an Elixir project through a library called [instructor_ex](https://github.com/thmsmlr/instructor_ex).
It's a [very simple tool to generate an icebreaker question](https://peerpraises.com/icebreaker-generator) for when you're starting a meeting with coworkers and need to get through that initial awkwardness.

![A screenshot of the icebreaker generator](/images/icebreaker_gen.jpg)

Once I had it working locally, I figured it was not worth paying a dedicated server for it and decided to deploy it on a self-hosted Coolify server I already use to host Plausible Analytics (also written in Elixir btw).

Here is what I learned in the process:

# Nixpacks are simpler but less flexible

When creating a new application, you can choose between two deployment options: Nixpacks and Dockerfile.

Nixpacks are simpler but less flexible. They are a set of pre-defined configurations that are used to build and deploy your application. They are a good choice if you want to get up and running quickly, but they may not be suitable for more complex applications.
In my case, I had already validated that the mix release was working correctly, but ended up not using it because the [Elixir Nixpack](https://nixpacks.com/docs/providers/elixir) only supports running `mix compile`, `mix assets.deploy` and `mix ecto.setup`.

## Caveats

* The Nixpack doc mentions running `mix ecto.deploy` (a non-default task), but it actually doesn't. It runs `mix ecto.setup`.
* By default it reads the Elixir version from the `mix.exs` file. You need a `.elixir-version` file or a `NIXPACKS_ELIXIR_VERSION` environment variable to override this.
* At the time of writing this post, it didn't support Elixir 1.18. The maximum supported version is 1.17.

# Be careful with managed databases

The deployment was failing initially when running `mix ecto.setup` because my hosted Postgresql instance is setup on a managed service which already creates the database and user and doesn't let you drop/create db like you would on a dev environment. I had to customise the `ecto.setup` task to skip the database creation step on `:prod` environment.

# Environment variables in coolify

Coolify allows you to define environment variables for your application. There is a checkbox for each variable to enable its availability at build time. Since my DATABASE_URL variable was only used in `config/runtime.exs`, I didn't initially enable it at build time. Turns out it is required because of the aforementioned ecto related mix tasks. The good thing is the deployment logs will show you a warning if you forget to enable it.

# HTTPS

![A screenshot of the domains setting in Coolify](/images/coolify-domains.jpg)

Last little configuration detail: when you replace the default `domains` setting with your own domains, don't forget to use the `https` scheme. The nice part is that it's all you need to do to enable HTTPS for your application.
