Feature: Control Flow | Break out of a For loop

Example: Can be used to break out of a 'for' loop
    When running a clox file:
    ```
    for (var x = 1; x < 10; x = x + 1){
        print x;
        if (x > 3) break;
    }
    ```
    Then clox prints to stdout:
    ```
    1
    2
    3
    4
    ```

Example: Breaks out of the closest 'for' loop
    When running a clox file:
    ```
    for (var x = 1; x < 3; x = x + 1){
        print x;
        for (var y = 1; y < 8; y = y + 1){
            if (y > 3) break;
            print y;
        }
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
    for (;;){
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
        for (;;){
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
    for (var x = 0;;){
        var a;
        var b;
        {
            var c;
            break;
        }
    }
    ```
    # 0006/0007/0008 -> a/b/c are pushed on the stack
    # 0009           -> x/a/b/c are all popped at once by the break statement
    # 0014           -> c is popped in the regular flow
    # 0015           -> a/b are popped in the regular flow
    # 0020           -> x is popped in the regular flow
    Then the bytecode looks like:
    ```
    == code ==
    0000    1 OP_SKIP
    0001    | OP_JUMP          0001 -> 0021
    0004    | OP_CONSTANT           0   # 0
    0006    2 OP_NIL
    0007    3 OP_NIL
    0008    5 OP_NIL
    0009    6 OP_POPN               4
    0011    | OP_LOOP          0011 -> 0001
    0014    7 OP_POP
    0015    8 OP_POPN               2
    0017    | OP_LOOP          0017 -> 0006
    0020    | OP_POP
    0021    | OP_RETURN
    13 opcodes (22 bytes), 1 constants
    ```