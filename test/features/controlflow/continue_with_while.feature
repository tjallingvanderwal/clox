Feature: Control Flow | Continue with While loop

Example: Can be used to continue with a 'while' loop
    When running a clox file:
    ```
    var x = 0;
    while (x < 5){
        x = x + 1;
        print x;
        if (x > 2) continue;
        print 'x';
    }
    ```
    Then clox prints to stdout:
    ```
    1
    "x"
    2
    "x"
    3
    4
    5
    ```

Example: Continues with the closest 'while' loop
    When running a clox file:
    ```
    var x = 1;
    while (x < 3){
        x = x + 1;
        var y = 1;
        while (y < 8){
            print x;
            y = y + 1;
            if (y > 3) continue;
            print y;
        }
    }
    ```
    Then clox prints to stdout:
    ```
    2
    2
    2
    3
    2
    2
    2
    2
    2
    3
    2
    3
    3
    3
    3
    3
    3
    3
    ```

Example: Syntax error: Missing ';'
    When running a clox file:
    ```
    while (true){
        continue
    }
    ```
    Then clox fails with:
    ```
    [line 3] Error at '}': Expect ';' after 'continue'.
    [line 3] Error at end: Expect '}' after block.
    ```

Example: Semantic error: 'continue' outside of a loop
    When running a clox file:
    ```
    continue;
    ```
    Then clox fails with:
    ```
    [line 1] Error at 'continue': No loop to 'continue' with.
    ```

Example: Continue from inside multiple nested scopes
    When running a clox file:
    ```
    if (true) { // create scope to ensure 'canary' is a local
        var canary = 345;
        var a = 0;
        while (a < 3){
            a = a + 1;
            var b = 2;
            if (a > 0){
                var c = 3;
                switch (b){
                    case 2: {
                        var d = 4;
                        if (d == 4){
                            var e = 5;
                            continue;
                        }
                    }
                }
            }
            print a; // never printed
        }
        print canary;
    }
    ```
    Then clox prints to stdout:
    ```
    345
    ```

Example: Bytecode for continuing from inside of nested scopes
    When compiling:
    ```
    while (true){
        var a;
        var b;
        {
            var c;
            continue;
        }
    }
    ```
    # 0008/0009/0010 -> a/b/c are pushed on the stack
    # 0011           -> a/b/c are all popped at once by the continue statement
    # 0016           -> c is popped in the regular flow    
    # 0017           -> a/b are popped in the regular flow
    Then the bytecode looks like:
    ```
    == <script> ==
    0000    1 OP_SKIP         
    0001    | OP_JUMP          0001 -> 0022
    0004    | OP_TRUE         
    0005    | OP_JUMP_IF_FALSE 0005 -> 0022
    0008    2 OP_NIL          
    0009    3 OP_NIL          
    0010    5 OP_NIL          
    0011    6 OP_POPN               3
    0013    | OP_LOOP          0013 -> 0004
    0016    7 OP_POP          
    0017    8 OP_POPN               2
    0019    | OP_LOOP          0019 -> 0004
    0022    | OP_RETURN       
    13 opcodes (23 bytes), 0 constants
    ```