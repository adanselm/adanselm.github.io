---
layout: post
title:  "From Modern C++ to Modern Web Applications 3: ObeseBird UI"
date:   2015-02-24 11:33:00
categories: programming coffeescript isomorphic react flux javascript
comments: true
---

### A real life example : ObeseBird

After all those buzzwords, it is now my turn to come up with a stupid name.

I decided to create an application to post tweets of specific categories to my
twitter feed following a given schedule. This way I could automagically post
about music every Wednesday at noon, and about tech every Monday morning.

I know there are tools to do that already. But we didn't make them ourselves,
so, by definition, they suck (don't deny it, we all think that way!).

Also, this will allow us to:

1. Code a front-end to really understand what we've only touched so far
2. Talk about an awesome language, [Elixir](http://elixir-lang.org/)
3. Code the back-end using Elixir + [Phoenix](http://www.phoenixframework.org/)

But this article is long enough as it is, so I'm afraid you'll have to wait for
the next one. Tons of fun ahead!

```
$ tree
.
├── Gruntfile.coffee
├── actions
│   └── loadPage.coffee
├── app.coffee
├── client.coffee
├── components
│   ├── About.jsx
│   ├── Application.jsx
│   ├── Home.jsx
│   ├── Html.jsx
│   └── Nav.jsx
├── configs
│   └── routes.coffee
├── package.json
├── server.coffee
└── stores
    └── ApplicationStore.coffee
```

[coffeescript]: http://coffeescript.org/
[jsx]: http://facebook.github.io/react/docs/jsx-in-depth.html
[flux]: http://facebook.github.io/flux/docs/overview.html
[fluxxor]: http://fluxxor.com/what-is-flux.html
[fluxible]: http://fluxible.io

[javascriptref]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference
