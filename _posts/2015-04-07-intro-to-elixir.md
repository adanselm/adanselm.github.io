---
title:  "From Modern C++ to Modern Web Applications 4: Introduction to Elixir"
date:   "2015-04-07 11:23:00"
categories: programming distributed system elixir erlang
permalink: "/blog/:year-:month-:day-from-modern-cpp-to-modern-web-app-4"
thumbnail: "/images/knight-rider.gif"
---

Read the previous articles in the serie here:
[Part 1](/blog/2015-02-03-from-modern-cpp-to-modern-web-app-1),
[Part 2](/blog/2015-02-24-from-modern-cpp-to-modern-web-app-2),
[Part 3](/blog/2015-03-03-from-modern-cpp-to-modern-web-app-3)

Behold the sexiest language I've seen in years!

![Knight Rider hey ladies](/images/knight-rider.gif)

## Erlang, the patriarch

I can't really talk about Elixir without mentioning Erlang first.

[Erlang][erlang] is a mature language developed by Ericsson in the eighties, and
open-sourced in 1998. It powers many Ericsson routers, so you're probably
using it when sending a [dick pic][john oliver] to your girlfriend without even noticing...

Now it is used in production by many big names: Github, WhatsApp, Facebook,
Grindr, etc.

### Erl-whaaaa?

An executive summary of the language would look something like that:

* Functional language
* Dynamically typed
* __"Prolog-y"__ syntax
* Runs on a VM
* Super lightweight because of its history in embedded systems
* Spawning thousands of concurrent processes is the norm (they're __NOT__ OS processes)
* Processes communicate via message-passing
* Distributing your application on several nodes doesn't require much code change
* Recursion and pattern-matching make it easy to read code
* You can even hot-swap code (although it is not easy)
* Battlefield-tested for more than 20 years
* Only 30 engineers work at WhatsApp, and they're dealing with millions of users.

Some people despise its syntax. I don't really care, it's still easier to read
than a Perl regex...
Here is an example module containing the factorial function:

<script src="https://gist.github.com/adanselm/829460980bf8c0bb8005.js"></script>

As you can see, recursion is highly recommended in Erlang. You don't have to
worry about efficiency, the compiler optimizes it for you.

Coming from C++, you'll probably notice some kind of function polymorphism
as well. The `fac` function has 2 different bodies: the first one returns 1
when the function parameter evaluates to 0, the second one returns N times fac(N-1).
Note that there is no "return" keyword. The function returns the value of the
last expression in its body.

The big difference with C++ is that you don't dispatch using the (static)
function signature (e.g. arguments types and qualifiers),
since there is no type, but rather using the dynamic content of those arguments.

Together with recursion, this leads to very concise code. Function bodies are
usually super short, since you rarely write loops at all, rather small functions
with different entry conditions and an accumulator. So if you end up writing
nested loops, chances are you have a big code smell.

### Let it crash

![OTP supervisor one-for-one](/images/erlang-restart-one-for-one.png)

[(Image courtesy of "Learn You Some Erlang")][learn you some supervisor]

Erlang also comes with something called [OTP][learn you some otp].
It stands for "Open Telecom Platform",
which doesn't really explain what it is, except that it is coming from a telecom
technology company.

Basically, OTP is an application framework for Erlang. They're both so
intertwined, that we should just call everything Erlang, really. OTP allows you
to structurally define applications: what servers or daemons does it contain,
how failures should be handled, and factorizes a lot of the
code so that you only have to write a few callbacks and a little bit of config
to get a super robust application structure.

It is considered robust, because of the Erlang philosophy of __"Letting it crash"__.
Which means that you don't design your program defensively, by trying to think
of all the edge cases and shit that could happen and how to prevent them.
Rather, you'd focus on how to recover from an error, because you're 100% certain
bad things will happen someday. And OTP forces you to methodically consider
these possibilities.

### Concurrency made easy

If you're a C++ developer, the simple evocation of the word "concurrency"
should be synonym of "painful memories": threads, mutexes, semaphores and
dining philosophers.

If not, you're weird. Honestly. Nobody likes to debug a threading problem.

Here, it is much simpler: you spawn a process, you send it a message. You don't
care if the data is copied or not, the VM takes care of it for you. You don't
care if you have 8 cores on your machine or just 1, the VM takes care of
spreading the load for you.

Sure, this also means you don't control everything. But if you do want to,
you can still spawn a C++ port from your Erlang program to do a specific task,
and still benefit from the robustness brought by OTP's supervision trees to
restart any failing task.

As always in computer science, the idea is to leverage the advantages of each
technology. I wouldn't write a game using Erlang. But when it comes to
server-side code, I wouldn't want to use anything else than Erlang or Elixir
anymore.

## Elixir is the bomb

I hope it's clear for you now that Erlang by itself is pretty cool already.
But what if I told you that its principles are now available in a more
conventional form factor, thus making it easier to learn for the developer
who wants the whole power of this great technology, with a smoother learning
curve?

That's exactly what Elixir is, and much more.

### A bit of history

![Elixir's creator, Jose Valim](/images/elixir-jose-valim.jpg)

Jose Valim, the creator of Elixir, was a core member in the Ruby community,
who decided to create a new language when he realized that Ruby's architecture
wasn't fit for an efficient concurrency model. Instead of building everything
from scratch, he looked around and found Erlang. He liked the concepts,
and ended up writing a language that relies on the same Virtual Machine.

This way, you get all the good stuff, and are able to tune the syntax.

So what is Elixir exactly? It's not just a different flavour of Erlang, it is
a new language using the same VM, with interesting features:

* It is fully interoperable with Erlang. You can call Erlang code from Elixir and
Elixir code from Erlang
* It comes with a package manager
* It comes with `mix`, a command line tool to manage the repetitive tasks
* It comes with a documentation system and unit-testing framework

I strongly recommend that you watch [this talk][erlang factory jose valim] to
learn more about its specificities.

### Code that's easy to read

Have a look at this unit-test from an actual project of mine and inspired by
[this article][json phoenix]:
<script src="https://gist.github.com/adanselm/3df936e68b5e01f91940.js"></script>

It creates a __User__ struct with a few fields, inserts it into the database,
encodes it to JSON, then queries our HTTP server for the "/api/users" path
and checks that it responds with the proper data and code.

In my opinion, it is very easy to understand with very little knowledge of
the language itself. For several reasons:

* Elixir macros made it possible to define a test case using the "test" keyword
and a string. Macros are powerful, although as in any language, too much of them can
be harmful.
* The `|>` pipeline operator clarifies the chain of operations nicely.

Combined with the other Erlang features that I mentioned above, such as
pattern matching, I personally find it very pleasant to write in Elixir.

I'm not proficient in Ruby, and many people say that this syntax is very close
to what can be found in this language, but the underlying concepts still are
those of a functional language, and you shouldn't just translate your
object-oriented ruby code to Elixir without redesigning it.

To know more about the syntax itself, take a look at the very concise
[getting started][elixir getting started] guide.

### The benefits of starting with a clean slate

Furthermore, its standard library is more comprehensible for the beginner.
Since it didn't have to be backward-compatible with any existing code, the
language creators were able to lay things out differently.

For example, when dealing with a distributed Erlang application, you'll usually have to
use functions from various modules: the `connect_node/1` function is in the
`net_kernel` module, the `ping/1` function is in the `net_adm` module,
and the `spawn/3` function is in the core. The creators of Elixir reorganized
the modules into a cleaner layout. So all those functions related to nodes
operations are now in the "Node" module. But you can still use the old ones
with a direct call to Erlang from Elixir if you want to!

Once you're familiar with its syntax, you should definitely look at the
["portal" tutorial][how i start elixir], which will help you embrace the
distributed power of the language.

Next time, we'll start coding our obese-bird app's backend using
[Phoenix Framework][phoenix], an equivalent for Ruby-on-Rails in the Elixir world.

In the meantime, you can meet me at the [Elixir Conf EU in Krakow][elixir conf eu]
at the end of the month.


[erlang]: http://www.erlang.org/
[john oliver]: https://www.youtube.com/watch?v=XEVlyP4_11M
[learn you some supervisor]: http://learnyousomeerlang.com/supervisors#supervisor-concepts
[learn you some otp]: http://learnyousomeerlang.com/what-is-otp
[erlang factory jose valim]: https://www.youtube.com/watch?v=Lqo9-pQuRKE
[json phoenix]: https://robots.thoughtbot.com/testing-a-phoenix-elixir-json-api
[elixir getting started]: http://elixir-lang.org/getting-started/introduction.html
[how i start elixir]: http://howistart.org/posts/elixir/1
[phoenix]: http://phoenixframework.org
[elixir conf eu]: http://elixirconf.eu/
