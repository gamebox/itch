# Itch

A simple textual language for creating Scratch projects.

An example:

```itch
# This is a comment
# The first line should explain what kind of target this is
sprite Test.

# Then we can set the initial values for the target attributes.  This is the same values found in the panel below the player.
set x = 188.
set y = 65.
set size = 100.
set direction = 90.
set layerOrder = 1.

# Then you give the name of the image assets you want to use as costumes.
# Images are stored in `assets/images` with the given name followed by either the `svg` or `png` extension.
costume "Cat_Walking".
costume "Cat_Flying".

# This is the same as above, but for sounds.  The extensions that are supported are only "wav".
sound "Meow".

# Any messages you wish to broadcast from this sprite should be listed like this.
broadcast "message1".

# Any variables that are scoped to this sprite should be defined like this with the initial value set.
var foobar = 0.

# Any lists that are scoped to this sprite should be defined like this with the initial value set.
list baz = [].

# All topic level blocks are prefixed with `block`
# A block is structured much like blocks in scratch, with interleaving words and inputs.
# A [] represents the label of a dropdown field and will be translated to the correct value.
# A () represents a reporter block (those with rounded ends, or angled ends).
# A simple string value can be placed in ""s.
# A simple number value can be used as is.
# A {} represents a "mouth", a slot where a series of stack blocks could be placed
# One unique choice made in itch is that all "hats" have an implicit mouth at the end where the rest of the script is placed.
block when flag clicked {
    set [foobar] to 5.
    say "Hello world!" for 5 secs.
    switch costume to [Cat_Flying].
}.
```

## Installation

### Prerequisites

1. Dart SDK > 3.5.0
2. POSIX-compatible operating system

```sh
git clone ssh:git@github.com:gamebox/itch.git
dart compile exe bin/itch.dart
mv itch.exe itch
# Add itch to your PATH
```

## Usage
```
Usage: itch <flags> [arguments]
-h, --help       Print this usage information.
-v, --verbose    Show additional command output.
    --version    Print the tool version.

Commands
------
compile
-f, --file (mandatory)    The path to a itch project directory
```

## Roadmap

1. Support for Windows / non-POSIX OS.
2. Support for single sprites.
3. Support for importing a Scratch project or sprite.
4. Create a new project from a template.
5. [Long Range] Create a new player/VM based on Dart/Flutter
6. [Long Range] Create a run/play edit cycle with Dart/Flutter VM.
7. [Long Range] Implement novel features in Dart/Flutter VM and language.
