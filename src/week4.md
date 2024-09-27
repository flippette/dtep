# Learning Diary

Week 4, 27/09/2024  
DTEP 24  
Le Quang Dat

For all of my Rust talk, I sure haven't been using it in this course, right?

Well, this changes today.

## Getting Rust to run on Arduino Uno

Yes, I did that this week. At last, I no longer have to suffer at the hands of
an aging language, and at the implicit nature of a library that pretends the
world is nice and simple.

At last.

But it certainly is a little bit more involved than how Rust embedded is
usually. The Rust compiler does not ship with a pre-built standard library
package for the target (`avr-unknown-gnu-atmega328`), so I had to switch to
the `nightly` toolchain to be able to compile it myself. Then, I enabled some
flags to ~~violently coerce~~ gently nudge the code size to better fit in the
chip's measly 32KB of flash. And finally, I used the `avr-hal` crate [1] to better
able to safely interface with the board's hardware, and I was then able to
write business logic.

What do I get out of this? Well, first of all, I no longer have to touch C++,
letting me ~~reclaim my sanity~~ be absolutely reassured that my code is both
safe and efficient, so I can focus on getting work done (next week, anyway).
In that vein, whatever setup cost I paid for will rapidly pay off as I do
non-trivial things, such as exotic data structures, which I can just use the
vast Rust crate ecosystem of high-quality, well-audited code that I can rely on.
Even if I don't want to blindly trust random code, I can both review the source,
as well as run the code through Miri [2], Rust's equivalent of the C/C++ world's
UBsan [3], but much more reliable since it's able to access the same information
that the compiler has, instead of having to blindly guess at runtime behavior.

I did write the code for Week 1's exercise in Rust, and not only did the code
look a lot nicer, it's also more maintainable, and the resulting binary was
also smaller than what the Arduino GCC compiler gave me, even with using serial.
Plus, the Rust code didn't have to busy loop to check for button presses, and
instead it used interrupts, which are done in a much safer way than C/C++ thanks
to the `avr-hal` crate and its `#[interrupt]` macro, all while saving power.
To even declare an interrupt in C/C++, you have to use a function that just
looks like any other function, hope that you remember which function it is,
carefully avoid spending too much time in there, and then procedurally bind it
in the `setup` function. With the `#[interrupt]` macro, you just need to name
your function the interrupt it's supposed to handle, and then attach the
attribute. If you get the name wrong, the compiler will complain. That's right,
it won't do nothing, it won't silently do the _wrong_ thing at runtime, it won't
crash without logging, it will tell you, at _compile-time_, that you made a
mistake. It's truly things like these that make Rust feel very well designed,
minimizing the possibility for human error that's featured prominently in
_The Design of Everyday Things_ [4]. ~~(totally not a contrived reference)~~

## ...and other stuff

This week's lecture was about the design process, emphasizing storyboarding as
a way for designers to step into users' shoes, to understand their needs better.
I don't have much to say here, this week was mostly about the thing above.

\newpage

## References

[1] Rahix, `avr-hal`, GitHub. <https://github.com/Rahix/avr-hal>  
[2] The Rust team, `miri`, GitHub. <https://github.com/rust-lang/miri>  
[3] The LLVM team, _UndefinedBehaviorSanitizer_, Clang documentation.
<https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html>  
[4] D. Norman, _The Design of Everyday Things: Revised and Expanded Edition_.
Massachusetts, USA: MIT Press, 2013.
