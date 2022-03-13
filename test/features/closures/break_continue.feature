Feature: Closures | Combined with the 'break'/'continue' statement

Example: A local is correctly converted to a closed upvalue when jumping out of a loop
    When running a clox file:
    ```
    var x;
    while (true){
        var y = 3;
        fun z(){
            return y; // <-- captures local variable from a scope that does end regularly
        }
        x = z;
        break; // <-- custom/forced end of scope
        // <-- regular end of scope
    }
    print x();
    ```
    Then clox prints to stdout:
    ```
    3
    ```

Example: A local is correctly converted to a closed upvalue when continuing with a loop
    When running a clox file:
    ```
    var x;
    while (x == nil){
        var y = 3;
        fun z(){
            return y; // <-- captures local variable from a scope that does end regularly
        }
        x = z;
        continue; // <-- custom/forced end of scope
        // <-- regular end of scope
    }
    print x();
    ```
    Then clox prints to stdout:
    ```
    3
    ```