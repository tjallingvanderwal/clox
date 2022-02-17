Feature: Command Line | Invalid combinations of options

Example: Selecting more than one run modus
    When running clox with "--repl --eval"
    Then clox fails with:
    ```
    More than one option out of [--eval, --file, --repl] given. Dunno what you want.
    ```           
    When running clox with "--file --eval"
    Then clox fails with:
    ```
    More than one option out of [--eval, --file, --repl] given. Dunno what you want.
    ```           

Example: Unknown flag
    When running clox with "--unknown"
    Then clox fails with:
    ```
    Unknown command line flag: --unknown.

    Usage: clox [FLAGS]
    Usage: clox [FLAGS] --repl
    Usage: clox [FLAGS] --eval "expression"
    Usage: clox [FLAGS] --file path/to/file
    
    Flags:
        --bytecode     Print generated bytecode
        --help         Print this message
        --memory       Show contents of the clox-heap while tracing
        --no-run       Do not run the program
        --trace        Show execution of each instruction and state of the stack
    ```