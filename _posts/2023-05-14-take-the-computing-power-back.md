---
title:  "Take the (computing) power back"
date:   "2023-05-14 11:23:00"
categories: programming eco thoughts
permalink: "/blog/:year-:month-:day-take-the-computing-power-back"
thumbnail: "/images/lisp-machine.jpg"
canonical: "https://www.ecohackers.co/p/take-the-computing-power-back?r=260wji&utm_campaign=post&utm_medium=web"
---

During my years studying engineering at the university, I had an AI class with an old teacher who had the tendency to forget the main subject of the course and tell stories from the time he was working at various computer science labs in the US instead.

Most students hated it. I loved it.

To me, this was way more precious than some technological knowledge I could always learn about in books.

I learnt how Xerox labs invented the mouse and graphical user interfaces, but got their ideas stolen from all sides. I learnt Lisp was such a popular language (due to the advances in AI at the time) that they even had “[Lisp Machines](https://en.wikipedia.org/wiki/Lisp_machine)” that could run the Lisp interpreter faster.

![A Lisp Machine (source https://en.wikipedia.org/wiki/Lisp_machine)](/images/lisp-machine.jpg)

And there was also a trend of keeping the compute-heavy logic on big expensive servers and having cheap lightweight terminals on the client side for the operators to do their work.

Nowadays, we still have that trend of running most of the logic on a server (in the cloud), but at the same time, we also have super powerful portable computers on the client side. Part of this power is used to improve the user experience tremendously, and work with high-resolution assets, but a lot of it is also wasted by running several instances of a web browser for each app built for the web that needed a standalone version.

Then you end up with a $3000 powerhouse of a computer that takes 3 seconds to open a big file.

On the server side, the expectations are such that even the most basic app has content replicated in different regions all over the globe, an AI-enabled support chatbot that eats kilowatts of GPU power to answer your customers questions 24/7, and nearly 100% service availability.

A few weeks ago I came across this presentation from Peter Van Hardenberg that talks about coming back to “Local-first software”, and it resonated with me. He basically expressed out loud what I had felt inside for so long.

<iframe width="560" height="315" src="https://www.youtube.com/embed/KrPsyr8Ig6M?si=ymBPT8cvMW5LasSl" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

I now like to think about the tools I use in terms of efficiency and some changes to my setup:

As a code editor, instead of VSCode, I use [Zed](https://zed.dev/) (still in development, so missing a bunch of features) or [LunarVim](https://github.com/LunarVim/LunarVim). They're both super responsive while not requiring 2 days of tuning just to start working.

If you run Docker containers a lot, have a look at alternatives to the vanilla Docker Desktop runtime, such as [OrbStack](https://orbstack.dev/) (still in beta, Linux and Mac only). In my case, it made a big difference in CPU and memory usage.

To take notes, I use [Craft](https://www.craft.do/) instead of Notion. It doesn't have all the database features of Notion, but it turns out, I don't need them. I you're on Mac, Apple Notes is also a pretty good fit 80% of the time.

Honestly, it also made me reconsider the apps that come with my OS. Leveraging the shared libraries that are already loaded in memory anyways makes them start up faster. If you take into account Subscription Fatigue on top of that, good old local software has never been more attractive.

And you? What efficient alternatives did you end up adopting, consciously or not?
