It all started when I spotted an [article](http://www.lightercapital.com/blog/howto-use-dropbox-to-organize-your-startups-documents) on hacker news about managing startup's documents through dropbox. Until then we were just putting our ideas for Springbeats on Google Docs (now Drive), before that we had a private wiki, and before that we had a private forum to discuss our ideas, as we were 3 collaborators, all living hundreds of kilometers away from each other.

Google Docs was perfectly fine until more consistent documents (such as a business plan or a financial forecast) came into play, as well as UML schemas and screenshots and so on.

So I bought Office for Mac and we progressively moved our documents to a shared folder in dropbox. But we then ran into several problems:

    Concurrent editing sucked compared to Google Docs
    We ran out of space
    I fancied being able to access my documents from everywhere and having a backup somewhere safe, so I wanted the same for my personal data, which led me to number 2 again

Avoid concurrency through organization

We still don't have any real technical solution to number 1. Even if my editor creates a lock file when it opens a document, there is still a dark zone between the time the lock file gets detected and synchronized all the way to my colleague's workstation. If he opens the same document during that time, the last one to save wins, basically (as it will erase what the other one did). If it's a plain text file, it's ok because we can just grab both versions and do a merge. But if it's an image file... it's an epic fail.

But actually that's not a big deal. What we did is a bit like what open source projects do, we defined responsibilities. We divided our corporate documents into sections such as "finance", "marketing", "recruiting hot hostesses", and so on, and we distributed the ownership. This way, when I want to rework on our business plan, I warn Denis first, and if Denis wants to edit a VAT calc sheet, he's supposed to ask me first, but in that particular case I'm all good because this stuff is so boring I'm pretty sure we won't conflict on its edition.

In the end, we don't find ourselves in conflict that much anymore, because we have very few big documents that are inclined to be modified on a regular basis.

Put technical docs closer to the code

Keeping dropbox for work because I don't want everything to be copied on my laptop.
