exe:
    dart compile exe bin/itch.dart
    cp bin/itch.exe ~/.local/bin/itch

clean:
    rm bin/itch.exe

test:
    dart test **/*_test.dart
