# Learning Diary

Week 3, 20/09/2024  
DTEP 24  
Le Quang Dat

This week was quite uneventful, we only really pitched ideas to our group and
the class. I noticed that some ideas mentioned were just overcomplicated,
requiring full-blown electronic systems to perform tasks that can be much more
easily and reliably performed another way: someone mentioned a system to
prevent apartment doors from locking if the key isn't outside with the owner,
which sounds good at first, but can also be made much more bulletproof by just
using a regular mechanical lock. I understand that these systems are contrived
and only even remotely considered due to the project at hand, but it rubs my
engineer brain the wrong way regardless.

At the exercise session, I misread the assignment related to Morse code. I had
_thought_ that I was to _decode_ Morse code into ASCII, but I was actually to
_encode_ ASCII to Morse code. However, I still think that my implementation of
the decoder was somewhat interesting, so I'll write about it here. Instead of a
simple lookup table which runs in ${O(n^2)}$ time, I opted to implement a
Morse code decoding tree as shown on Wikipedia [1], which only requires ${O(n)}$
time, but involves dynamic memory allocation and pointer chasing, things you
shouldn't casually do on embedded platforms.

Here is a shortened version of the implementation:

```c
#include <stdlib.h>
#include <string.h>

struct node {
  char ch;
  struct node *dit;
  struct node *dah;
};

struct tree {
  struct node *dit;
  struct node *dah;
};

/* lazily initialize a global decoding tree */
struct tree *get_tree() {
  static bool init = false;
  static struct tree dec_tree = {
    .dit = NULL,
    .dah = NULL,
  };

  if (init) return &dec_tree;

  /* EXPUNGED: Actually initialize the tree here */

  init = true;
}

struct dec_result {
  char ch;
  size_t pos;
};

struct dec_result dec(struct tree *dec_tree, char *key) {
  struct dec_result result = {
    .ch = 'X',
    .pos = 0,
  };

  size_t key_len = strlen(key);
  if (!key_len) return result;

  struct node *cur;
  switch (key[0]) {
    case 'S':
      if (!dec_tree->dit) return result;
      cur = dec_tree->dit;
      break;
    case 'L':
      if (!dec_tree->dah) return result;
      cur = dec_tree->dah;
      break;
    default:
      return result;
  }

  size_t pos = 1;
  while (pos < key_len) {
    switch (key[pos++]) {
      case 'S':
        if (!cur->dit) return result;
        cur = cur->dit;
        break;
      case 'L':
        if (!cur->dah) return result;
        cur = cur->dah;
        break;
      case 'P':
        goto END;
      default:
        return result;
    }
  }

END:
  result.ch = cur->ch;
  result.pos = pos;
  return result;
}
```

Once again, just like last week, I am constantly reminded of the numerous
papercuts in the C language, especially how the compiler does nothing to help
the programmer handle `NULL` values, leading to either an ergonomic, safety,
or performance deficit, and usually all 3 at the same time (in the example, I
just completely neglected to check the validity of the `dec_tree` pointer
parameter in the `dec` function.) A scarier bug that C does nothing to help you
prevent is synchronization. Global variables without locks are a great hazard
to correctness: even in a single-threaded environment, interrupts can just waltz
in and completely corrupt any sensitive invariant. To contrast these with Rust
(again), `NULL` values are explicitly handled with the `Option` type, and
mutable globals are completely inaccessible without the use of either `unsafe`
code, or some synchronization primitive (in normal environments, the standard
library provides a `Mutex` implementation, and in embedded, the ecosystem crate
`critical-section` provides a portable mechanism for synchronization.)

After spending roughly way too long on the decoder, I realized I did the wrong
thing, and started work on the encoder, which is much less interesting: it is,
in fact, just a lookup table. In the current implementation, I had it write
continuously to the serial bus, this may prove to be a problem, but it's easy
enough to write to a dynamically allocated string buffer. Still, I very much
dread C strings: how they use a null byte as a delimiter, requiring a full
traversal for even a simple `strlen` call, as well as completely not supporting
UTF-8, the encoding that literally everyone uses.

Am I being too harsh on C? Maybe. It's older than much of the alternatives I've
mentioned, and as of now, it's still the _lingua franca_ of programming
languages: every language worth its salt must be able to interoperate with C.
I just think that, 50 years after its birth, the time has come to replace it
with a modern alternative, incorporating decades upon decades of research on
programming languages and type systems. Norman argues [2, pg. 90, 91] that
"humans err continually," and that "blaming the person without fixing the root,
underlying cause does not fix the problem," stating "why was the system ever
designed so that a single act by a single person could cause calamity?". To
think that a book about design could fit so well when discussing a programming
language, truly goes to show the ever-present importance of good design.

\newpage

## References

[1] Wikipedia editors, _Morse code_, Wikipedia. <https://en.wikipedia.org/wiki/Morse_code#Alternative_display_of_common_characters_in_International_Morse_code> (accessed September 20, 2024).

[2] D. Norman, _The Design of Everyday Things: Revised and Expanded Edition_.
Massachusetts, USA: MIT Press, 2013.
