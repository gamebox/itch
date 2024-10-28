# Itch

A simple textual language for creating Scratch projects.

An example:

```itch
sprite Test.

set x = 188.
set y = 65.
set size = 100.
set direction = 90.
set layerOrder = 1.

costume "costume1".
costume "costume2".

sound "Meow".

broadcast "message1".

var foobar = 0.

list baz = [].

block when flag clicked {
    set [foobar] to (5).
    switch costume to [costume1].
    set rotation style [all-around].
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
