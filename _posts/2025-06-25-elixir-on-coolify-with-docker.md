---
title:  "How I switched my self-hosted Elixir Phoenix project from mix to docker in Coolify"
date:   "2025-06-25 11:25:00"
categories: programming elixir coolify docker
permalink: "/blog/:year-:month-:day-elixir-on-coolify-docker"
thumbnail: "/images/coolify2.png"
---

In my previous note on [how to deploy an Elixir Phoenix project on a self-hosted Coolify instance](/blog/2025-05-13-elixir-on-coolify/), I ended up using the default Nixpack mode because it appeared to be the quickest way to get started.

Turns out having a running docker container is kinda even faster!

# Why the switch?

I wouldn't have explored the docker mode yet if I had not run into a problem with the latest Phoenix RC that was causing issues with the deployment process.

A libc version mismatch was preventing my assets to build. So after looking into the issue a bit and not finding where I could customize the Node/Bun version to use in the Nixpack, I decided not to lose more time on something I don't master. I'm more familiar with Docker and I knew I could customize the configuration to not have the same issue.

# Thanks, generator!

The awesome part is that you don't even have to do anything really to generate a Docker file. Just run:

```bash
mix phx.gen.release --docker
```

And that's pretty much it!

# Final docker file

I only tweaked 2 things from the generated file:

* changed the base container versions
* and enabled Tini

Here is what I ended up with:

```dockerfile
# Find eligible builder and runner images on Docker Hub. We use Ubuntu/Debian
# instead of Alpine to avoid DNS resolution issues in production.
#
# https://hub.docker.com/r/hexpm/elixir/tags?name=ubuntu
# https://hub.docker.com/_/ubuntu/tags
#
# This file is based on these images:
#
#   - https://hub.docker.com/r/hexpm/elixir/tags - for the build image
#   - https://hub.docker.com/_/debian/tags?name=bookworm-20240926-slim - for the release image
#   - https://pkgs.org/ - resource for finding needed packages
#   - Ex: docker.io/hexpm/elixir:1.17.3-erlang-27.1-debian-bookworm-20240926-slim
#
ARG ELIXIR_VERSION=1.17.3
ARG OTP_VERSION=27.3.4
ARG DEBIAN_VERSION=bookworm-20250428-slim

ARG BUILDER_IMAGE="docker.io/hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="docker.io/debian:${DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE} AS builder

# install build dependencies
RUN apt-get update \
  && apt-get install -y --no-install-recommends build-essential git \
  && rm -rf /var/lib/apt/lists/*

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force \
  && mix local.rebar --force

# Set mix env to prod
ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

RUN mix assets.setup

COPY priv priv

COPY lib lib

COPY assets assets

# compile assets
RUN mix assets.deploy

# Compile the release
RUN mix compile

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

COPY rel rel
RUN mix release

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM ${RUNNER_IMAGE} AS final

RUN apt-get update \
  && apt-get install -y --no-install-recommends libstdc++6 openssl libncurses5 locales ca-certificates curl \
  && rm -rf /var/lib/apt/lists/*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
  && locale-gen

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

WORKDIR "/app"
RUN chown nobody /app

# set runner ENV
ENV MIX_ENV="prod"

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/peerpraises ./

# If using an environment that doesn't automatically reap zombie processes, it is
# advised to add an init process such as tini via `apt-get install`
# above and adding an entrypoint. See https://github.com/krallin/tini for details
ENV TINI_VERSION=v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

USER nobody
ENTRYPOINT ["/tini", "--"]

CMD ["/app/bin/server"]
```

Then you just switch to Docker build mode in Coolify's configuration UI, and you're good to go.

Honestly, had I known it was that simple, I'm not even sure I would have bothered with the Nixpack mode.
