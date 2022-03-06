Feature: Control Flow | Continue with For loop

Example: Can be used to continue with a 'for' loop
    When running a clox file:
    ```
    for (var x = 1; x < 5; x = x + 1){
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
    ```

Example: Continues with the closest 'for' loop
    When running a clox file:
    ```
    for (var x = 1; x < 3; x = x + 1){
        for (var y = 1; y < 8; y = y + 1){
            print x;
            if (y > 3) continue;
            print y;
        }
    }
    ```
    Then clox prints to stdout:
    ```
    1
    1
    1
    2
    1
    3
    1
    1
    1
    1
    2
    1
    2
    2
    2
    3
    2
    2
    2
    2
    ```

Example: Syntax error: Missing ';'
    When running a clox file:
    ```
    for (;;){
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
        for (var a = 1; a < 10; a = a + 1){
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
    for (var x = 0;;){
        var a;
        var b;
        {
            var c;
            continue;
        }
    }
    ```
    # 0006/0007/0008 -> a/b/c are pushed on the stack
    # 0009           -> a/b/c are all popped at once by the continue statement
    # 0014           -> c is popped in the regular flow    
    # 0015           -> a/b are popped in the regular flow
    # 0020           -> x is popped in the regular flow    
    Then the bytecode looks like:
    ```
    == <script> ==
    0000    1 OP_SKIP         
    0001    | OP_JUMP          0001 -> 0021
    0004    | OP_CONSTANT           0   # 0
    0006    2 OP_NIL          
    0007    3 OP_NIL          
    0008    5 OP_NIL          
    0009    6 OP_POPN               3
    0011    | OP_LOOP          0011 -> 0006
    0014    7 OP_POP          
    0015    8 OP_POPN               2
    0017    | OP_LOOP          0017 -> 0006
    0020    | OP_POP
    0021    | OP_NIL          
    0022    | OP_RETURN       
    14 opcodes (23 bytes), 1 constants
    ```