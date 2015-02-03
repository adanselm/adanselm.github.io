One of the things you notice first when you start reading about music making software is that software companies LOVE giving hundreds of technical details about their products. Some nerds like to compare the different products and see which list is longer, but most people (including me, although I'm nerdy too) don't read it and prefer to see, in context, what difference it makes.

The technical argument we've been hearing a lot for the past two years is "we have a 64bit product, and those suckers don't". Ok, fine, but what does it even mean? Let's dig into the heart of the machine! ;)
Computer architecture for the dummies
To better understand what's at stake here, let's take a quick look at how computers work (very basically don't worry). If you are a computer engineer, close your eyes, and please don't mind the shortcuts that are taken in my explanations (and above all, please don't send me anonymous letters describing my future death).

You probably know that microprocessors are made of millions of transistors. That's a number manufacturers often use to describe how evolved their products are. For instance, a 2008 Intel core i7 has 731000000 (731 million) transistors. A transistor is an electronic component (a semi-conductor) which has several properties, one of which is particularly interesting for computers: an electrical current will flow from one side (the emitter) to the other (the collector) only if there is enough voltage applied to its third side (the base).

I know what you want to say. You want to say: "Where the hell is he taking us? We're not in physics class anymore". You're right. But that's all you needed to know really. The memory inside your computer is just a big grid of transistors. If the current goes through one of its cells, it means it has retained a value of 1. If no current goes through it's a 0. That's why your computer only thinks in ones and zeros. Every data is encoded in binary form in the end, so that it can be stored and used for computation.

Millions of times per second, the microprocessor inside your computer (or tablet, phone, car, whatever) puts some data in its internal memory, does operations on it, and puts it back somewhere else. How it does that is another story, but the important thing here is it operates on binary data composed of bits (the ones and zeros).

Now until recently, general purpose microprocessors used to operate on 32 bits, meaning that every cycle processed 32 bits at a time. Note that it doesn't mean they were not able to do calculation on numbers coded in 64 bits: technically speaking, you could compute each part separately and assemble the result. This extra work would need to be orchestrated by the running application or special optimizations built in the CPU, but basically it required more time! So in terms of computation, what 64 bit computers bring is:

    Faster computation on big numbers, and probably on other operations as well if they can be bulked to benefit from the doubled size
    More precision on floating point numbers, since there is more room to store what you have after the point


In fact, we'll see that the computing part is not what matters the most in this transition to 64 bits...
Next step: the operating system
