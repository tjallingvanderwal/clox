Feature: Control Flow | Break out of a While loop

Example: Can be used to break out of a 'while' loop
    When running a clox file:
    ```
    var x = 1;
    while (x < 10){
        print x;
        if (x > 3) break;
        x = x + 1;
    }
    ```
    Then clox prints to stdout:
    ```
    1
    2
    3
    4
    ```

Example: Breaks out of the closest 'while' loop
    When running a clox file:
    ```
    var x = 1;
    while (x < 3){
        print x;
        var y = 1;
        while (y < 8){
            if (y > 3) break;
            print y;
            y = y + 1;
        }
        x = x + 1;
    }
    ```
    Then clox prints to stdout:
    ```
    1
    1
    2
    3
    2
    1
    2
    3
    ```

Example: Syntax error: Missing ';'
    When running a clox file:
    ```
    while (true){
        break
    }
    ```
    Then clox fails with:
    ```
    [line 3] Error at '}': Expect ';' after 'break'.
    [line 3] Error at end: Expect '}' after block.
    ```

Example: Semantic error: 'break' outside of a loop
    When running a clox file:
    ```
    break;
    ```
    Then clox fails with:
    ```
    [line 1] Error at 'break': No loop to 'break' out of.
    ```

Example: Break out of multiple nested scopes
    When running a clox file:
    ```
    if (true) { // create scope to ensure 'canary' is a local
        var canary = 345;
        var a = 1;
        while (true){
            var b = 2;
            if (a > 0){
                var c = 3;
                switch (b){
                    case 2: {
                        var d = 4;
                        if (d == 4){
                            var e = 5;
                            break;
                        }
                    }
                }
            }
        }
        print canary;
    }
    ```
    Then clox prints to stdout:
    ```
    345
    ```

Example: Bytecode for breaking out of nested scopes
    When compiling:
    ```
    while (true){
        var a;
        var b;
        {
            var c;
            break;
        }
    }
    ```
    # 0008/0009/0010 -> a/b/c are pushed on the stack
    # 0011           -> a/b/c are all popped at once by the break statement
    # 0016           -> c is popped in the regular flow
    # 0017           -> a/b are popped in the regular flow
    Then the bytecode looks like:
    ```
    == <script> ==
    0000 1 OP_SKIP
    0001 | OP_JUMP 0001 -> 0022
    0004 | OP_TRUE
    0005 | OP_JUMP_IF_FALSE 0005 -> 0022
    0008 2 OP_NIL
    0009 3 OP_NIL
    0010 5 OP_NIL
    0011 6 OP_POPN 3
    0013 | OP_LOOP 0013 -> 0001
    0016 7 OP_POP
    0017 8 OP_POPN 2
    0019 | OP_LOOP 0019 -> 0004
    0022 | OP_RETURN
    13 opcodes (23 bytes), 0 constants
    ```