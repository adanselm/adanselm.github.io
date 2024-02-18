---
title:  "From Modern C++ to Modern Web Applications 5: JSON API with Elixir and Phoenix"
date:   "2015-06-16 11:23:00"
categories: programming distributed system elixir json phoenix api
permalink: "/blog/:year-:month-:day-from-modern-cpp-to-modern-web-app-5"
thumbnail: "/images/mcferrin.jpg"
---

Read the previous articles in the serie here:

- [Part 1](/blog/2015-02-03-from-modern-cpp-to-modern-web-app-1),
- [Part 2](/blog/2015-02-24-from-modern-cpp-to-modern-web-app-2),
- [Part 3](/blog/2015-03-03-from-modern-cpp-to-modern-web-app-3),
- [Part 4](/blog/2015-04-07-from-modern-cpp-to-modern-web-app-4)

Finally, after visiting Poland and attending the [European Elixir Conference][elixir conf eu],
and after working on the latest version of [AutoTheory][autotheory] (to be released soon), I can
conclude this serie of articles and write about the Phoenix Framework.

## What is Phoenix?

[Phoenix][phoenix] is a CMS (Content Management System) written in Elixir.
Not a CMS in the sense of Wordpress or Drupal,
with an existing user interface to write posts, rather in the sense of a framework
to serve pages (or any other kind of HTTP response) with dynamic content.

For the rubyists out there (which I'm not), think Ruby On Rails.

It is structured in the traditional Model-View-Controller way, letting you serve
the same content in different formats if you need to, and choose the persistent
layer you want (we'll use Postgres as the database layer though).

On top of this, it perfectly leverages the `mix` tool coming with Elixir to
conduct the usual tasks that come with such projects.

To give you an example, have a look at a typical Router module from a Phoenix application:

<script src="https://gist.github.com/adanselm/8bfb4c78ed9d6c350329.js"></script>

This defines the URL scheme of your application. Every call to an endpoint
inside /api will go through the "api" pipeline, which defines a set of filters
called "Plugs" that the request will go through first.

Then the `resources` command will create a set of REST routes for the given URL.
It lets you define:

* The URL (based on the existing scope) of this resource in your application
* The controller which will handle this resource
* A list of operations to exclude or, on the contrary, the exclusive list of operations allowed
* Nested paths inside this resource. Here each user can have several `subs` associated.

Running `mix phoenix.routes` gives you a detailed list of the routes that have
been created:

<script src="https://gist.github.com/adanselm/3bf4197879b3edefdf05.js"></script>

Thus, if we issue a GET operation on our server's `/api/users/3` URL (matching
the second line of this list), it will
call the `show/2` function inside the `UserController` module, with an argument
containing the number `3` as the requested `:id`. Needless to say, it won't
work until you actually implement the functions in these modules!

If you're familiar with HTTP requests, you should notice how concise the
definition of the router is.

Beware though, Phoenix is evolving very fast, so by the time you decide to use the code in this
article, it might be obsolete already, so as always, you should try to
understand the concepts and have a look at the official page, especially the
migration guides from version to version.

Let's dive into our real application now.

We will base this guide on three existing articles, that did not exist when
I started using Phoenix, but are a great starting point now if you already
know the basics of the language:

* [Building a blazing fast JSON api with Phoenix][elixir json api]
* [Building a versioned REST API with Phoenix][phoenix versioned]
* [Continuous deployment of Phoenix apps with Travis and Heroku][phoenix travis heroku]

## The Obese Bird API

![Bobby McFerring: Don't worry be happy](/images/mcferrin.jpg)

If you remember our previous articles correctly, you know we need to provide
the following data to be able to create and schedule tweets properly:

* Create/edit/delete post categories
* Create/edit/delete tweets in a given category
* Create/edit/delete time-slots in the schedule for a given category

### Creating resources

Follow [the user guide][getting started] to install Phoenix. Then create a new
project, and delete the pre-generated stubs:

```
$ mix phoenix.new obesebird_api --no-brunch
$ rm web/controllers/page_controller.ex web/views/page_view.ex test/controllers/page_controller_test.exs test/views/page_view_test.exs
```

The `no-brunch` option tells phoenix not to bother creating an asset packaging
task, which is useful when you have images, CSS, javascript, etc that you
want to transform before putting them in your project. `Brunch` is the name of
the tool used for this purpose. We don't need this here since we're only
doing a JSON api that will manipulate text data. And it will greatly simplify
the testing and deployment process. Let's keep it simple at first. You're big
enough to take it to the next level by yourself when you feel like it.

We now have a clean slate, with a base application which does nothing.
Thankfully, Phoenix provides mix tasks to generate a skeleton of code for us.
Based on the operations our application needs to be able to fulfill, we can call
the `phoenix.gen.json` task to create our 3 resources: categories, posts and slots:

```
$ mix phoenix.gen.json Category categories name:string
$ mix phoenix.gen.json Post posts text last_submission_date:datetime category:belongs_to
$ mix phoenix.gen.json Slot slots day_of_week:integer hour:integer min:integer category:belongs_to
```

This does many things under the hood: creating a model, view, controller for this
particular resource and their associated tests, plus the SQL operations to create
this schema in the database.

The task doesn't modify existing files for us though, so we need to edit our
`web/router.ex` file to give each of these resources an URL:

<script src="https://gist.github.com/adanselm/7c75584feb4285317fbb.js"></script>

Now have a look at `mix phoenix.routes` to see all the functions you will have
to implement :)

### Local and Test Database setup

Since we intend to use Travis for continuous testing, we need to comply with
their database settings. Make sure your local Postgres database can be accessed
through user `postgres` and an empty password.

Then, edit the `config/dev.exs` and `config/test.exs` to reflect this change.

Finally, create and structure your local database:

```
$ mix ecto.create
$ mix ecto.migrate
```

### Versioning the API

Since APIs tend to evolve with time, you often have to make several versions
of the API cohabit on your server while your users migrate from one version to
the other (or don't migrate at all, most of the time...). It is thus a good
practice to clearly separate the code for each version from the beginning.

[This article][phoenix versioned] gives pretty good instructions to accomplish just this.
We'll just follow (almost) blindly.

Moving files to a `v1` subdirectory:

```
$ mkdir web/controllers/v1
$ mkdir web/views/v1
$ mkdir test/controllers/v1
$ mv web/views/post_view.ex web/views/v1
$ mv web/views/category_view.ex web/views/v1
$ mv web/views/slot_view.ex web/views/v1
$ mv web/controllers/*.ex web/controllers/v1
$ mv test/controllers/*.exs test/controllers/v1
```

Adding the `V1` namespace to the module names and the helper functions:

```
$ sed -i '' 's/defmodule ObesebirdApi/defmodule ObesebirdApi.V1/' web/controllers/v1/*.ex web/views/v1/*.ex test/controllers/v1/*.exs
$ sed -i '' 's/post_path/v1_post_path/' test/controllers/v1/*.exs                                                                                                                                                               (master✱)
$ sed -i '' 's/category_path/v1_category_path/' test/controllers/v1/*.exs                                                                                                                                                       (master✱)
$ sed -i '' 's/slot_path/v1_slot_path/' test/controllers/v1/*.exs
```

Changing the views code to add an argument to the `render_many` and `render_one`
functions (see the article above for explanations):

```
$ sed -i '' 's/, "category.json"/, ObesebirdApi.V1.CategoryView, "category.json"/' web/views/v1/category_view.ex
$ sed -i '' 's/, "post.json"/, ObesebirdApi.V1.PostView, "post.json"/' web/views/v1/post_view.ex
$ sed -i '' 's/, "slot.json"/, ObesebirdApi.V1.SlotView, "slot.json"/' web/views/v1/slot_view.ex
```

Now if you run `mix test`, you should still get errors saying that you can't
query for categories. That's a bug in the generator that I have [filed][bug].
You can fix it simply like this:

```
$ sed -i '' 's/category: nil, //' test/controllers/v1/post_controller_test.exs test/controllers/v1/slot_controller_test.exs
```

Now all the tests should pass, we can keep on setting the perfect development
pipeline up.

### Setting up deployment to production (heroku)

Edit `config/prod.secret.exs` to make it read every parameter from environment
variables:

<script src="https://gist.github.com/adanselm/fc69d8aa6f032e408843.js"></script>

This way we can just tell heroku what our secrets are and commit the code
in a public repository safely. Copy your `secret_key_base` somewhere before
overwriting it. You also need to remove `config/prod.secret.exs` from `.gitignore`
and commit it as well, since we now exclusively use environment variables inside.

Now let's create our heroku application and configure it.
You need the heroku and travis CLI to make this work.

```
$ heroku create --buildpack "https://github.com/HashNuke/heroku-buildpack-elixir.git" obesebird-api
$ heroku config:set PORT=80
$ heroku config:get DATABASE_URL
postgres://your_user:your_pass@your_hostname:your_port/your_db_name
```

A free database addon should have been created with this buildpack. Letting you
read a configuration from DATABASE_URL.
Using `heroku config:set`, set the SECRET_KEY_BASE variable with the value you saved
from `config/prod.secret.exs`.

Create an `elixir_buildpack.config` file containing:

```
# Export heroku config vars
config_vars_to_export=(PORT DATABASE_URL SECRET_KEY_BASE)
```

And add it to git.
I also commented the `manifest.json` setting in `config/prod.exs`.

Running `git push heroku master` after committing should now load your api in production. Then
create the database with `heroku run mix ecto.migrate`.

Finally, add a `Procfile` containing

```
web: yes | mix compile.protocols && elixir -pa _build/prod/consolidated -S mix phoenix.server
```

and commit it. Then repush to heroku. You should now be able to target your
heroku api with, say:

```
$ curl https://yourapp.herokuapp.com/api/v1/categories
{"data":[]}
```

Yay! An empty list! :)

### Continuous testing and deployment with Travis

Create a `.travis.yml` file containing:

<script src="https://gist.github.com/adanselm/4df6968f19988400e8f2.js"></script>

Then run `travis encrypt $(heroku auth:token) --add deploy.api_key` to put your
encrypted heroku token inside instead of mine.

Now if you commit, push to your public Github account and activate the continuous
build in your Travis account interface, you should be able to automatically
test every commit, and let Travis push it to production by itself once the tests are
validated!

Isn't it a nice workflow? :)

### Refining the API

![Refining oil](/images/refining.jpg)

What we've done so far, is let code generators create a basic JSON api to
Create/Retrieve/Update/Delete our resources (Category, Post and Slot), and
set a nice workflow up so that a push on the repository automatically drives
the test phase, then the deployment to production.

But the resources that were created are not complete yet. If you try to insert
a category on your local instance and then retrieve it:

```
$ curl -i -H "content-type: application/json" -d '{"category": {"name": "misc"}}' 127.0.0.1:4000/api/v1/categories
HTTP/1.1 200 OK
Connection: keep-alive
Server: Cowboy
Date: Mon, 22 Jun 2015 12:46:34 GMT
Content-Length: 17
Content-Type: application/json; charset=utf-8
Cache-Control: max-age=0, private, must-revalidate

{"data":{"id":1}}

$ curl 127.0.0.1:4000/api/v1/categories/1
{"data":{"id":1}}
```

You will notice you only have the `id` of the newly created entity in return.
That's because we need to customize the view, which defines the fields we want
to display. So in `category_view.ex`, add the category name to returned
structure:

```
...
  def render("category.json", %{category: category}) do
    %{id: category.id, name: category.name}
  end
...
```

The same goes with `slot_view.ex`:

```
...
  def render("slot.json", %{slot: slot}) do
    %{id: slot.id, day_of_week: slot.day_of_week, hour: slot.hour,
      min: slot.min, category_id: slot.category_id}
  end
...
```

and `post_view.ex`:

```
...
  def render("post.json", %{post: post}) do
    %{id: post.id, text: post.text, category_id: post.category_id,
    creation_date: post.inserted_at,
    last_submission_date: post.last_submission_date }
  end
...
```

Since we modified the way the resources are displayed, we also need to update
the tests accordingly. For instance, with the `slots`:

```
  test "shows chosen resource", %{conn: conn} do
    slot = Repo.insert %Slot{}
    conn = get conn, v1_slot_path(conn, :show, slot)
    assert json_response(conn, 200)["data"] == %{
      "id" => slot.id,
      "category_id" => slot.category_id,
      "day_of_week" => slot.day_of_week,
      "hour" => slot.hour,
      "min" => slot.min
    }
  end
```

### Sending tweets

We will use the [ExTwitter][extwitter github] library to interact with Twitter
from our application.

Add it to your project's dependencies in `mix.exs`:

```
defp deps do
  [
  ...
  {:oauth, github: "tim/erlang-oauth"},
  {:extwitter, "~> 0.2"}]
end
```

and run `mix deps.get` to download it.

Browse to the [twitter applications page][twitter apps], create an application,
generate a token, and set matching variables CONSUMER_KEY, CONSUMER_SECRET,
ACCESS_TOKEN, ACCESS_SECRET with `heroku config:set CONSUMER_KEY=abcdefg`.

Add the twitter configuration to your `config/prod.secret.exs`:

```
config :ex_twitter, :oauth, [
  consumer_key: System.get_env("CONSUMER_KEY"),
  consumer_secret: System.get_env("CONSUMER_SECRET"),
  access_token: System.get_env("ACCESS_TOKEN"),
  access_token_secret: System.get_env("ACCESS_SECRET")
]
```

As before, this will read the configuration from the variables we set through
heroku in production.

Now, let's write a small module in `lib/obesebird_api/tasks.ex` to check the
database for posts in a given category and publish the least recently published one:

<script src="https://gist.github.com/adanselm/8bf8cfc6210e7e9ce3ff.js"></script>

The first function, `get/2`, serves as a helper to list the upcoming time-slots
of the day. If you've defined that on wednesdays you want to publish one tweet
of category 1 (e.g. 'Company Life') at 8am, one tweet of category 2 ('Misc') at
1pm, and one tweet of category 3 ('Jobs') at 6pm, then calling `get(3, {10, 00, 00})`
will give you a list with the 2 last Timeslots of the day.

Then `get_next_post/1` will simply pick the next message to publish for a given
category by looking at all the predefined tweets, and ordering them by their
last publication date.

Finally, executing a publication in a category simply means calling `get_next_post`,
publish the text of this post on twitter with the help of `ExTwitter.update(text)`,
and update the last publication date, so that this post appears at the end of
the queue when calling `get_next_post` again.

Pretty simple, right?

You can validate that this works by temporarily replacing the `ExTwitter.update`
call by an `IO.puts` call, creating a few categories, posts and
timeslots, and manually triggering `execute/1`.

### Scheduling the tweets

![Alice White Rabbit](/images/alice-white-rabbit.jpg)

The last, and probably most important part for our application, is to create the logic that will
trigger the publications at the time defined in our agenda.

There are several ways to deal with this problem. I decided to keep things simple
and create a little daemon in `lib/obesebird_api/scheduler.ex` which will wake up
every day at midnight, check for
the tasks of the day, and sleep until it's time for the next task.

Elixir/Erlang provide the GenServer behaviour for server creation. We just
have to implement a few callbacks, so that:

* The server recognizes a `:check` message, which triggers a schedule check
* At `init`, we send ourselve this `:check` message

Then, checking for tasks is just a matter of computing what is the day of the
week with the Erlang function `:calendar.day_of_the_week/1`, and delegating
the process of looking for the agenda for this day to our `Tasks` module.

* If there is no task to manage, the daemon sleeps until midnight the next day
(unless it is restarted, which we will do in case the agenda changes).
* If there is a task to manage, but the time has not come yet, the daemon sleeps
until this particular time
* If there is a task to manage right now, the daemon asks our `Tasks` module
to trigger the publication of the corresponding tweets category.

<script src="https://gist.github.com/adanselm/2645849a50fa91fc2356.js"></script>

In order to automatically start our scheduler and make it restart in case
of problem, we add it to our application's supervisor, in `lib/obesebird_api.ex`:

```
children = [
  # Start the endpoint when the application starts
  supervisor(ObesebirdApi.Endpoint, []),
  # Start the Ecto repository
  worker(ObesebirdApi.Repo, []),
  # Start the tweets scheduler
  worker(ObesebirdApi.Scheduler, [[name: ObesebirdApi.Scheduler]]),
]
```

If the time slots change, we simply stop the scheduler manually. Its supervisor
will restart it automatically, which will make it check for new tasks.
We do that by calling `ObesebirdApi.Scheduler.stop(ObesebirdApi.Scheduler)`
every time we change (create/update/delete) the schedule in `web/controllers/v1/slot_controller.ex`.

### Important notes

If you really intend to use this, please note that it will require a paid plan
on Heroku, since the free plan will put your dyno to sleep after 30 minutes,
which would make our scheduler pretty useless!

I'm conscious of the limitations:

* the tasks should run in a separate process to avoid slowing the scheduler down,
* there are cases where tasks can be skipped without noticing,
* the API has no security at all (meaning anyone could edit your tweets :) ),
* it lacks many more tests,
* and the general robustness of the application might not be optimum,

but it still is a good exercise!

Finally, to complete our application, we should put the front-end and the back-end
together. It is pretty straight-forward, so I'll let you do it yourself.

Please let me know in the comments, on twitter or by email if you noticed
anything obviously wrong, if you want me to write about linking the front and
back end, or if you liked the article :)

[elixir conf eu]: http://elixirconf.eu/
[autotheory]: http://autotheorybymozaic.com/
[phoenix]: http://phoenixframework.org
[elixir json api]: https://robots.thoughtbot.com/testing-a-phoenix-elixir-json-api
[phoenix versioned]: https://renatomoya.github.io/2015/05/09/Building-a-versioned-REST-API-with-Phoenix-Framework.html
[phoenix travis heroku]: http://natescottwest.com/continuous-deployment-of-phoenix-apps-with-travis-and-heroku/
[getting started]: http://www.phoenixframework.org/v0.13.1/docs/up-and-running
[bug]: https://github.com/phoenixframework/phoenix/issues/972
[extwitter github]: https://github.com/parroty/extwitter
[twitter apps]: https://apps.twitter.com/
