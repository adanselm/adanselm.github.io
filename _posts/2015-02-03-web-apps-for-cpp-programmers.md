---
layout: post
title:  "From Modern C++ to Modern Web Applications"
date:   2015-02-03 19:35:53
categories: c++ programming
comments: true
---

![Funny picture of facebook on the minitel](/images/fb-minitel.jpg)

[(image source)](https://secure.flickr.com/photos/eogez/4271111360/)

**DISCLAIMER : This article contains rude language and way too many times the word "framework".**



It had been years since I hadn't done some programming for the web.

Last time I tried, it was pretty much just hitting its puberty as a technology.
At that time, web programmers were very proud to show that they were able to refresh parts
of a page with some dynamic content, Gmail was the ultimate web application,
and Java was still hype.

I obviously needed to refresh my knowledge on the subject.

After a couple of hours reading all about the latest fashion in incredibly
inefficient web programming habits, it hit me : these people are trying to solve
for the web the problems enterprise software had 40 years ago! Which I could
roughly summarize as : "Project is growing, we have clients that need updates
and pay good money for it, let's try to put some structure into this shit".

Wouldn't it be nice if we could just learn from our experience as C++ developers
and not fall for every new shiny technology, but rather have a clear look at
what we should study if we ever have to work on such a project? That's what
I'll try to do.

But first, a quick reminder of how our desktop and mobile apps are structured.

## A typical MVC C++ application for the desktop or mobile

It doesn't matter if you're making a game, a photo editor, or a porn stash
application, when there's a GUI and an application state to be stored in 
some way, you'll find that it's a good habit to divide your program in the
Model-View-Controller organization. Or one of its derivatives : MVP, MVVM, IMMVP,...
Okay, I just made that last one up, sorry.

Let me walk you through a reminder of how this usually works.

### The Holy Model

The model defines the canonical data your application needs in order to run.
If you're creating a porn stash app, then you need to store a data
structure somewhere, containing the characteristics of each entry of your collection: title,
release date, actresses, tags, notes, etc.

![A complicated model caricature](/images/designTech.jpg)

This data could be stored in a database, but we don't really care, because we
just manipulate instances of the classes that compose our Model. These instances
make up the state of our application. Serializing them to a file or to a
database to be able to continue working on our collection when we restart
the app is a personal choice.

### "Be pretty and shut up": The View

Despite what its name could imply, the Model isn't the one that has to be pretty.
In fact, it can even be really ugly, because we'll just hide it in the back while
the view takes all the credit for the knowledge it is displaying.

The way the view takes its data from the model depends on the type of pattern
you're using. In a framework such as Apple's Cocoa for instance, you would
design the view using a nice drag-and-drop interface and bind its fields with
slots in your ViewController object. This way, the view is shallow enough to
be serialized in an XML file, and is just there to define a layout. It is just
a "Presenter", hence the name, MVP.

Once this layout is opened, some code will create the actual widgets of your
user interface, and translate the connections that it describes into real
method calls. This way, when you click on a button, an action will be triggered
in your controller, and vice versa, when a field of data has changed in your
model, your controller will update the proper area of the view.

### The real smart: The Controller

Last but not least, is the entity that is actually **doing** something.
When you click a button to add an entry to your porn collection in your
view, it's the controller that will check the data and actually update the model.

In an MVP, it's also the controller that will *observe* the model for any change
that needs to be reflected in the view. In a typical MVC, the view would be in
charge of observing the model. Since it could
confuse people about who's doing what, I like the MVP approach better. Sometimes I'll say
MVC, but in my head I'll actually mean MVP. But don't worry, you're smart,
you'll figure it out. And since you're a C++ developer, you already know all
of this anyway.

### Action-Reaction round-trip

Let's summarize what happens when I click the "delete entry" in my collection
view. I hope you like my retro ASCII art skills!

![Flow from view to model and back](/images/mvc-flow.png)

Which can be summarized as:

  - Clicking the button triggers an action in the controller
  - Since the model is the master of the state of the program, we quickly modify it
  - The controller being an observer of the model, it is notified that there was a change in the collection
  - It updates the view according to those changes

[Check out Apple's doc on MVC for another take on this.][Apple MVC]

### GUI responsiveness

With all the respect due to the older generations, I don't want their user
interface. You know, those ugly buttons that were stuck while an action was
being processed in the background?

To avoid experiencing such helplessness in front of a computer, modern frameworks
let you play with threads in collaboration with a main event loop.

So when you retrieve a (legal!) file with your favorite bittorrent client, the
transfer actually happens in a separate thread, which posts regular progress
updates to the main event loop (in the main program thread), which will in turn
refresh the progress bar in your UI.

This can quickly become difficult to reason on, and you must adapt your
code organization to properly encapsulate such threads.

### Client-server applications

Quite often, enterprise software also heavily rely on a centralized model living
in a server.

In such a scenario, the model classes of your application would then act as a
proxy object, making network requests and caching the results behind the scenes. It is easily done
using sockets. Since the communication is bi-directional, the server would
notify you of any change in the model (initiated by another client for instance)
so that you could keep the displayed information up-to-date.

### Wrapping it up

So, this is the state of desktop (and mobile) applications as I know them :

  - We have well established frameworks such as Qt, JUCE, or Apple's Cocoa SDK
  that really accelerate the development of a desktop application
  - Best practices and designs take some time to learn, but once you master them,
  you know they're not going to radically change
  - The only system we have to fit into, for the people to use our application, 
  is the Operating System. Nothing forces you to use a particular protocol to
  communicate with your servers.

and that's what I want to keep in mind while jumping into the web tornado.

## Moving to the Web

While you were busy programming real-time 3D games that look like the pre-rendered
movies of last year, or a video editing tool that would leverage the power
of your 8 cores CPU, or a static analyzer that would allow your team to make
less mistakes in their code, ... well, during that time, web folks have written
a dozen javascript frameworks that all do the same, and a gazillion libraries
with random names carefully picked to disturb us from our mission :
understanding the big picture.

<iframe src="//giphy.com/embed/UJJqmGzg0nBPa?html5=true" width="480" height="360" frameBorder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>

But let's back up a notch first and reenact the history of web apps, shall we?

### Server-side MVC

At the root of all web applications is the need to form HTML/CSS pages that
are the main entities a browser can render.

When requesting a page, your browser sends an HTTP GET query to a particular URL,
and gets the content of the page in the body of the response.
People quickly realized that the content of the page could be populated by data
from a database, and that URLs could parameterize some pretty complex requests.

So when requesting a page, instead of simply serving a static HTML page, your
server instance would instead generate one dynamically.

> The URL you requested tells me you want to see the latest transactions on your
bank account? Very well, let me retrieve them from our DB, and generate a page
containing the list from a template I have prepared just for the occasion!

At that time, I remember being proposed to work on PHP and J2EE projects all
the time. Buzzwords like LAMP (Linux-Apache-MySQL-PHP) were everywhere.
Aaaahhh. Nostalgia!

![Phoenix Framework logo](/images/phoenixframework.png)

Nowadays, frameworks like Ruby On Rails or [Phoenix][phoenix] (my favorite!) make it
**really** easy to develop such backends.

### Scriptable Client

Then people got fed up of such a lack of interactivity.
The communication is only one way: browser request -> server response. So in my
beautiful porn-stash application, if I want more details about a starlet and
follow the link on her name, here comes the full page reload!

Luckily, browser already had support for a scripting language called 
JavaScript (later standardized as [ECMAScript](http://en.wikipedia.org/wiki/ECMAScript)),
and developers realized they could leverage its functionalities to request
data from the server in an asynchronous way, and modify the nodes constituting
the HTML page (the DOM, Document Object Model) with this data. This is called
AJAX, and the most popular library used to make it happen is jQuery.

The beginning of [this article][FEforRails] shows a typical AJAX call, dirty but functional:

```javascript
$(document).ready ->
  photoHTML = (photo) =>
    "<li>
       <a id='photo_#{photo.id}' href='#{photo.url}'>
         <img src='#{photo.url}' alt='#{photo.alt}' />
       </a>
    </li>"

  $.ajax
    url: '/photos'
    type: 'GET'
    contentType: 'application/json'
    onSuccess: (response) =>
      for photo in response.photos
        node = $(photoHTML(photo)).appendTo($("#photos-list"))

        node.on('click', (e) =>
          e.preventDefault()
          node.find('img').prop('src', 
            photo.url + '.grayscaled.jpg')
        )
    onFailure: =>
      $("#photo-list").append("<li>
                                 Failed to fetch photos.
                               </li>")
```

It is still a type of communication that requires a request from the browser,
and a response from the server though. If you need a persistent connection
between the two ends, enabling the reception of regular updates from the server,
check out WebSockets communications.

### Client-side MVC

As you probably noticed, the previous AJAX call isn't very structured.
It mixes data retrieval with view composition, and is not very easy to test.

It is more than enough if you just want to add some dynamic content to an
existing page here and there in a small project. But if your project is a big
application, and your business revolves around it, you might need bigger guns.

Frameworks like [AngularJS](https://angularjs.org), [Backbone.js](http://backbonejs.org)
or [Ember.js](http://emberjs.com) (and many others), are
designed to structure your *SPA* (Single Page Application). They have reusable
view components, a testing architecture, adapters to transform your backend
data into model classes, active communities, and tons of plugins.

### "The assembly language of the web"

If you're like me, now you're probably thinking: "Since everything works with
JavaScript, then I can just compile whatever language I like to JavaScript
through an LLVM toolchain and rock on!".

Well, Google has compiled Java to JavaScript
for years, and with C/C++, that's exactly what the combo [Emscripten][emscripten] +
[ASM.js][asm.js] does. It is still fairly early stage, but with promising results.

So if you're a game developer wanting to port a project to the browser, that's
good news!

### "Front-end servers" and Isomorphism

But if you're building the new Facebook-killer business, like half of the
teams that compete to a start-up pitching contest, you're not going to
become famous and have a movie made after your life if nobody can find you in a search engine...

Search Engine Optimization (SEO) is what helps customers find you and organically
come to you. But with a full JavaScript front-end, web crawlers can't read your page.
Because they don't interpret it.

To cope with this limitation, web developers are relying more and more on
server side JavaScript runtimes. You've probably heard of [Node.js](http://nodejs.org).
It's a server runtime that executes JavaScript. Following this logic, you're
then able to write JS code that will be used both on the server and in the browser.
That's what is referred to as *Isomorphism*. You don't have to completely separate
client code from server code. Once NodeJS has generated a first rendering of
your page, it is then transferred to the browser who will continue to execute
the rest of your interactive JS application.

![3 layers: the front-end, the front-end server, and the back-end](/images/node-fe-be.png)

I call it "Front-end server" because you still have your main backend containing
your data, that you can access both from Node to get the initial data to populate
your page, and from your browser to get/set the rest of your business logic.

The nerds at AirBnb summarized it pretty well in [this article][isojsairbnb].

### Applying it

To summarize, if we, C++ developers, want to develop a web application, we can
either:

  1. Port an existing C++ app to JavaScript using Emscripten and ASM.js, with
  the risk of being snobbed by search engines because our page is not searchable.
  2. Conceive a front-end in two steps, with a server side pre-render, thus enabling SEO.

Now if you're like me, you might be thinking: "The less JavaScript I have to touch,
the happier I am". And I'm pretty sure that thousands of developers can relate to
that. Just yesterday, I stumbled on this tweet:

[The reason why javascript sucks...](https://twitter.com/Sh1bumi/status/562008866322677761)

![The reason why javascript sucks](https://pbs.twimg.com/media/B8yoFc1IcAEl5_2.png:large)

And, in a way, this could be a non-problem, because we could just translate
any emscripten supported language to JS when building our application's
NodeJS module. It would just spit some JavaScript out, that your front-end server and
browser could run.

Fortunately, it's possible. Mostly through CoffeeScript, a beautified JavaScript.
Not so much through other high level languages... Probably because you'd need to
rewrite all the existing modules in order to include them in your code.

So I'll bite the bullet for now, and try fiddling with Node and React,
starting with [this Node and React tutorial][react and node tutorial].
It uses a library called [React.js][fb react] introduced by Facebook in the past months.
It helps you create reusable views that you will pre-render in Node.

The result of this investigation, how I managed to deal with CoffeeScript,
and how I organized the application overall, will come in due time.

For now, back to C++!

([See the next article in this serie here!]({% post_url 2015-02-24-web-app-frontend %}))

---

[Apple MVC]: https://developer.apple.com/library/mac/documentation/General/Conceptual/DevPedia-CocoaCore/MVC.html
[phoenix]: http://phoenixframework.org
[FEforRails]: http://blog.arkency.com/2014/07/6-front-end-techniques-for-rails-developers-part-i-from-big-ball-of-mud-to-separated-concerns/
[emscripten]: http://en.wikipedia.org/wiki/Emscripten
[asm.js]: http://en.wikipedia.org/wiki/Asm.js
[isojsairbnb]: http://nerds.airbnb.com/isomorphic-javascript-future-web-apps/
[react and node tutorial]: http://www.htmlxprs.com/post/20/creating-isomorphic-apps-with-react-and-nodejs
[fb react]: http://facebook.github.io/react/

[evolutionofreqres]: https://gcanti.github.io/2014/11/24/understanding-react-and-reimplementing-it-from-scratch-part-2.html
[tcomb]: https://gcanti.github.io/2014/09/12/json-deserialization-into-an-object-model.html
