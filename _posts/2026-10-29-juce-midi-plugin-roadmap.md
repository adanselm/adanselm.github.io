---
title:  "Your first MIDI plugin with JUCE: the roadmap I'd follow today"
date:   "2026-10-29 15:00:00"
categories: programming c++ juce audio midi
permalink: "/blog/:year-:month-:day-juce-midi-plugin-roadmap"
thumbnail: "/images/juce-midi-plugin.jpg"
---

A few months after we started Springbeats, I drove to Frankfurt with the trunk of my car full of computers and screens, to demo a music app at the Musikmesse on what I still believe was the crappiest booth in the history of the fair. Borrowed trestles, a printed poster, and a demo that didn't get much traction.

A few years later, in January 2017, the print edition of GNU/Linux Magazine France published an article I wrote about programming audio applications in C++ with [JUCE](https://juce.com/). It was in French, it was printed on actual paper, and it is now roughly as up to date as the booth.

JUCE has moved on a lot since then: JUCE 9 is out, CMake is a first-class citizen, and the Projucer is no longer the only way in. What hasn't changed is the question web developers ask when they peek at audio: _where do I even start?_

So here is the roadmap I'd follow today, assuming you're a web dev, you know some C++ (or are willing to pretend), and you only have a few hours a week. Six steps, one tiny plugin, and a chapter about crackles, because there is always a chapter about crackles.

# 1. Start with a MIDI effect, not a synth

Everybody wants to build a synth first. It's the audio equivalent of starting web development by writing your own browser.

A synth means oscillators, envelopes, filters, aliasing, and a lot of maths that will happily eat your evenings. A MIDI effect means taking notes in, changing them, and sending them out. No DSP. The results are instant, audible (through any instrument you already own), and you learn the whole plugin lifecycle without fighting a filter. Filters can wait. They're very patient. Mostly in a menacing way.

Good first MIDI effects:

* a **transposer** (shift every note by N semitones), which is what we'll build here,
* a **keyboard splitter** (notes below a split point go to MIDI channel 1, notes above to channel 2, so one keyboard can play bass and piano at once),
* a tiny **arpeggiator** (JUCE ships one as a demo, see `examples/Plugins/ArpeggiatorPluginDemo.h`).

No DSP doesn't mean no fun, by the way. Pure MIDI effects can get as clever as you like once the basics work. Play with time: humanize, swing, a MIDI delay, an arpeggiator that follows the host tempo. Or play with music theory: a harmonizer, a scale quantizer that keeps every note in key, chords from a single finger. The notes are only numbers, and the numbers don't complain.

# 2. Learn one class first: AudioProcessor

A JUCE plugin is, at its heart, one class deriving from [`juce::AudioProcessor`](https://docs.juce.com/master/classAudioProcessor.html). The host (your DAW) creates it, tells it the sample rate and block size in `prepareToPlay()`, then calls `processBlock()` over and over, for as long as the plugin lives.

`processBlock()` is where everything happens. An audio buffer and a MIDI buffer come in, you change them, they go out. The rest of JUCE (GUI, look-and-feel, the DSP module and its many friends) can wait.

## The project, with CMake

These days I'd skip the Projucer and go straight for CMake, using JUCE's [`juce_add_plugin`](https://github.com/juce-framework/JUCE/blob/master/docs/CMake%20API.md). Put JUCE next to your code (a `git clone` or a git submodule in a `JUCE` folder), and write a `CMakeLists.txt` like this one:

```cmake
cmake_minimum_required(VERSION 3.22)
project(TINY_TRANSPOSE VERSION 0.1.0)

add_subdirectory(JUCE) # JUCE cloned (or added as a git submodule) next to this file

juce_add_plugin(TinyTranspose
    COMPANY_NAME "Your Name"
    PLUGIN_MANUFACTURER_CODE Ynam  # 4 chars, at least one upper-case letter
    PLUGIN_CODE Ttr1               # 4 chars, exactly one upper-case letter
    FORMATS AU VST3                # AU is only built on macOS
    PRODUCT_NAME "Tiny Transpose"
    IS_MIDI_EFFECT TRUE
    NEEDS_MIDI_INPUT TRUE
    NEEDS_MIDI_OUTPUT TRUE
    COPY_PLUGIN_AFTER_BUILD TRUE)

target_sources(TinyTranspose PRIVATE PluginProcessor.cpp)

target_compile_definitions(TinyTranspose
    PUBLIC
        JUCE_WEB_BROWSER=0
        JUCE_USE_CURL=0
        JUCE_VST3_CAN_REPLACE_VST2=0)

target_link_libraries(TinyTranspose
    PRIVATE
        juce::juce_audio_utils
    PUBLIC
        juce::juce_recommended_config_flags
        juce::juce_recommended_lto_flags
        juce::juce_recommended_warning_flags)
```

The three MIDI flags matter: `NEEDS_MIDI_INPUT` and `NEEDS_MIDI_OUTPUT` say what they mean, and `IS_MIDI_EFFECT` lets hosts that have a dedicated MIDI effect slot put it there (more on that headache in step 5).

## The processor

Here is the header. Most of it is boilerplate that every plugin has to provide. The interesting bits are at the bottom.

```cpp
#pragma once

#include <juce_audio_utils/juce_audio_utils.h>
#include <array>

class TransposeProcessor final : public juce::AudioProcessor
{
public:
    TransposeProcessor();

    void prepareToPlay (double sampleRate, int samplesPerBlock) override;
    void releaseResources() override {}
    void processBlock (juce::AudioBuffer<float>&, juce::MidiBuffer&) override;
    using AudioProcessor::processBlock;

    bool acceptsMidi() const override  { return true; }
    bool producesMidi() const override { return true; }
    bool isMidiEffect() const override { return true; }
    double getTailLengthSeconds() const override { return 0.0; }

    // No custom UI yet: JUCE draws a slider for every parameter
    juce::AudioProcessorEditor* createEditor() override { return new juce::GenericAudioProcessorEditor (*this); }
    bool hasEditor() const override { return true; }

    const juce::String getName() const override { return "Tiny Transpose"; }
    int getNumPrograms() override { return 1; }
    int getCurrentProgram() override { return 0; }
    void setCurrentProgram (int) override {}
    const juce::String getProgramName (int) override { return {}; }
    void changeProgramName (int, const juce::String&) override {}

    void getStateInformation (juce::MemoryBlock& destData) override;
    void setStateInformation (const void* data, int sizeInBytes) override;

private:
    juce::AudioProcessorValueTreeState state;
    std::atomic<float>* semitones = nullptr;
    juce::MidiBuffer output;

    // For each channel and each incoming note: the note we actually sent (-1 = none)
    std::array<std::array<int, 128>, 16> sentNotes {};

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (TransposeProcessor)
};
```

A few things worth noticing coming from the web:

* `BusesProperties()` with nothing in it means _no audio at all_. This plugin only speaks MIDI.
* `AudioProcessorValueTreeState` holds the parameters. The host can automate them and save them with the project, for free.
* There is no custom UI. `GenericAudioProcessorEditor` draws a slider for each parameter. It's ugly, and it's perfect for now.

And the implementation:

```cpp
#include "PluginProcessor.h"

static juce::AudioProcessorValueTreeState::ParameterLayout createLayout()
{
    juce::AudioProcessorValueTreeState::ParameterLayout layout;
    layout.add (std::make_unique<juce::AudioParameterInt> (juce::ParameterID { "semitones", 1 },
                                                           "Semitones", -24, 24, 0));
    return layout;
}

TransposeProcessor::TransposeProcessor()
    : AudioProcessor (BusesProperties()), // MIDI only: no audio buses at all
      state (*this, nullptr, "STATE", createLayout())
{
    semitones = state.getRawParameterValue ("semitones");
}

void TransposeProcessor::prepareToPlay (double, int)
{
    output.ensureSize (4096); // allocate here, once, never in processBlock

    for (auto& channel : sentNotes)
        channel.fill (-1);
}

void TransposeProcessor::processBlock (juce::AudioBuffer<float>& buffer, juce::MidiBuffer& midi)
{
    buffer.clear(); // nothing to do with audio, but never leave garbage in it

    const auto shift = static_cast<int> (semitones->load());
    output.clear();

    for (const auto metadata : midi)
    {
        auto message = metadata.getMessage();

        if (message.isNoteOn())
        {
            const auto channel = static_cast<size_t> (message.getChannel() - 1); // 1-16 -> 0-15
            const auto played  = message.getNoteNumber();
            const auto sent    = juce::jlimit (0, 127, played + shift);

            sentNotes[channel][static_cast<size_t> (played)] = sent;
            message.setNoteNumber (sent);
        }
        else if (message.isNoteOff()) // also catches note-ons with velocity 0
        {
            const auto channel = static_cast<size_t> (message.getChannel() - 1);
            auto& sent = sentNotes[channel][static_cast<size_t> (message.getNoteNumber())];

            if (sent >= 0)
            {
                message.setNoteNumber (sent); // release the note we actually played
                sent = -1;
            }
        }

        output.addEvent (message, metadata.samplePosition);
    }

    midi.swapWith (output);
}

void TransposeProcessor::getStateInformation (juce::MemoryBlock& destData)
{
    if (auto xml = state.copyState().createXml())
        copyXmlToBinary (*xml, destData);
}

void TransposeProcessor::setStateInformation (const void* data, int sizeInBytes)
{
    if (auto xml = getXmlFromBinary (data, sizeInBytes))
        state.replaceState (juce::ValueTree::fromXml (*xml));
}

// JUCE calls this to create new instances of the plugin
juce::AudioProcessor* JUCE_CALLTYPE createPluginFilter()
{
    return new TransposeProcessor();
}
```

Two details make this transposer less naive than it looks.

First, `sentNotes` remembers, for every note you pressed, which note was actually sent. Without it, if you move the slider while holding a key, the note-off gets transposed by the _new_ amount, the synth never hears the release of the old note, and you get the classic stuck note. It's the MIDI version of leaving the tap running. (JUCE's `MidiKeyboardState` won't help here: it can tell you that a key is down, not which note you sent for it, and it takes a lock and calls listeners on the way.)

Second, the incoming MIDI events are copied into another buffer that was sized once in `prepareToPlay()`, then swapped back. That's step 3's fault.

# 3. Respect the audio thread

This is the real mindset shift when you come from web development.

On a server, if a request takes 30 ms longer than usual, nobody dies. Somebody's dashboard turns a slightly different shade of green. In a plugin, `processBlock()` runs on the audio thread, and it has to hand its buffer back before the sound card needs it. At 48 kHz with 128-sample blocks, that's under 3 milliseconds, every time, forever.

Think of the audio thread as a very small, very punctual god. It wants its buffer every few milliseconds, and it has never heard of "eventually".

So, inside `processBlock()`:

* **no memory allocation**: no `new`, no growing `std::vector`, no building `juce::String`s (yes, that includes your `DBG()` logging),
* **no locks**: a mutex held by the UI thread at the wrong moment is a missed deadline,
* **no file or network I/O**: not even "just a quick read of the settings file".

That's why the transposer uses a fixed-size `std::array` instead of a map, reads the parameter through an `std::atomic<float>*` (no lock needed), and reserves the output `MidiBuffer` up front. `MidiBuffer::addEvent()` can still allocate if you blow past the reserved size, which is fine for a first plugin but worth knowing.

Ross Bencina's [Real-time audio programming 101: time waits for nothing](http://www.rossbencina.com/code/real-time-audio-programming-101-time-waits-for-nothing) is still the best short read on the topic.

# 4. Test without a DAW

Loading your plugin in a full DAW for every change is slow, and DAWs have opinions. They mostly share them by crashing, or by quietly keeping an old scan of your plugin while you debug code you already fixed.

JUCE ships a small host for exactly this: the **AudioPluginHost**. Build it once from the JUCE folder:

```bash
cmake -B build -DJUCE_BUILD_EXTRAS=ON
cmake --build build --target AudioPluginHost
```

Then scan your plugin folder (on Linux, VST3 plugins live in `~/.vst3`), drop your plugin on the graph, wire the MIDI input to it, and its MIDI output into the built-in MIDI Logger, or into any instrument plugin you have. Play the on-screen keyboard, move the slider, play again. Save the graph once (it becomes a `.filtergraph` file), and you can reopen the same test bench in one command. Since you can launch the host from your debugger, you can put a breakpoint in `processBlock()` (just don't expect the audio to wait for you).

Open a real DAW only when it works in the host. And test in Release too: Debug builds of C++ code can be slow enough to crackle on their own, which is a great way to waste an evening on a bug that doesn't exist.

# 5. Ship one format first

`FORMATS AU VST3` builds both on a Mac. That's the easy part. The hard part is that "MIDI effect" doesn't mean the same thing everywhere:

* **AU**: Logic has a real MIDI FX slot, and `IS_MIDI_EFFECT TRUE` lands you there. Gotcha: Logic only calls your `processBlock()` when there is an instrument on the track.
* **VST3** has no concept of a MIDI effect. Most hosts load MIDI plugins as instruments with a MIDI output, and the user routes that output to another track. Depending on the host, you may also need a (silent) audio output bus for it to behave. Read the [JUCE forum threads](https://forum.juce.com/t/midi-effect-plugin-characteristic-best-practice/59826) about it before promising anything on a product page.

That's the setup we document for VelPro: its VST3 version goes on a MIDI track, you route its MIDI output to your instrument, and the curves for each track are saved with the DAW project. It also ships as a standalone app that creates its own virtual MIDI input, for when you'd rather fix your keyboard once for every app on the machine than plugin by plugin.

So my advice: pick **one** format and **one** host, the ones _you_ use, and make one tiny feature work perfectly there. You can add formats later. You can't easily un-ship a plugin that hangs a user's session the night before a gig.

And before you sell anything, read the licence. JUCE is dual-licensed under the AGPLv3 and its own commercial licence. At the time of writing, the [JUCE 9 licence](https://juce.com/get-juce/) has a free **Starter** tier for revenue up to $20,000 over the previous 12 months, then paid **Indie** and **Pro** tiers above that. If you'd rather not pay, the AGPLv3 route means open-sourcing your plugin. Check the actual [EULA](https://juce.com/legal/juce-9-licence/) yourself, not my summary. Lawyers, like audio glitches, are much cheaper to avoid than to fix.

# 6. Why does it crackle?

The thread version of this article promised this chapter, so here it is. A MIDI effect can't crackle on its own (it doesn't touch audio), but sooner or later you'll write something that does, and it _will_ crackle. Here are the usual suspects, in the order I'd check them:

1. **You missed the deadline.** Allocation, a lock, a log line, a file read in `processBlock()`. See step 3. This is the cause most of the time.
2. **Denormals.** Very small floating-point numbers (typically a reverb tail fading into silence) can make some CPUs dramatically slower. Put `juce::ScopedNoDenormals noDenormals;` at the top of `processBlock()`. It costs nothing and saves hours.
3. **Parameter jumps.** A gain going from 0.2 to 0.8 in one sample is a click. Do it on every block, and you get "zipper noise". Ramp the value over a few milliseconds with `juce::SmoothedValue`.
4. **Garbage in the output.** If your plugin has more output channels than input channels, the extra ones may contain whatever was in memory. Clear what you don't write to (JUCE's default plugin template does exactly that, for a reason).
5. **Assuming the block size.** `samplesPerBlock` in `prepareToPlay()` is a maximum, not a promise. Hosts may send smaller blocks, especially around loops and automation. Always use `buffer.getNumSamples()`.
6. **It's not you.** A Debug build, an overloaded machine, a tiny buffer size in the host settings. Check those before rewriting your DSP.

And the MIDI cousin of the crackle is the stuck note, which we already dealt with in step 2. You're welcome.

# Where to go from here

Once the transposer works, open the DSP module. Filters have been waiting patiently, and you now know enough about the audio thread to keep them happy.

This is more or less the kind of tool I've been building with [Springbeats](https://springbeats.com) for years. [VelPro](https://springbeats.com/velpro) is the concrete example: a JUCE app and VST3 plugin, for Windows and macOS, that lets you draw a custom velocity curve for each note of your keyboard. Under the editor, the undo/redo and the presets, it's the same family as the transposer: notes come in, get fixed, go out.

If you build your first MIDI plugin after reading this, I'd love to hear about it. You can find me on X ([@adanselm](https://x.com/adanselm)) and Bluesky ([@adrienanselme.com](https://bsky.app/profile/adrienanselme.com)).

And you? What would _your_ first MIDI effect do?
