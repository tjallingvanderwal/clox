Feature: Variables | Bytecode generated for local variables

Example: Bytecode for a scope without local variables
    When compiling:
    ```
    { print 1; }
    ```
    Then the bytecode looks like:
    ```
    == <script> ==
    0000    1 OP_CONSTANT           0   # 1
    0002    | OP_PRINT
    0003    | OP_NIL
    0004    | OP_RETURN
    4 opcodes (5 bytes), 1 constants
    ```

Example: Bytecode for a scope with a single local variable
    When compiling:
    ```
    {
        var x = 1;
    }
    ```
    # 0000 -> The var is created
    # 0002 -> The var is discarded using OP_POP
    Then the bytecode looks like:
    ```
    == <script> ==
    0000    2 OP_CONSTANT 0 # 1
    0002    3 OP_POP
    0003    | OP_NIL
    0004    | OP_RETURN
    4 opcodes (5 bytes), 1 constants
    ```

Example: Bytecode for a scope with three local variables
    When compiling:
    ```
    {
        var x = 1;
        var y = 2;
        var z = 3;
    }
    ```
    # 0000 -> x is created
    # 0002 -> y is created
    # 0004 -> z is created
    # 0006 -> All three vars are discarded using OP_POPN
    Then the bytecode looks like:
    ```
    == <script> ==
    0000    2 OP_CONSTANT           0   # 1
    0002    3 OP_CONSTANT           1   # 2
    0004    4 OP_CONSTANT           2   # 3
    0006    5 OP_POPN               3
    0008    | OP_NIL
    0009    | OP_RETURN
    6 opcodes (10 bytes), 3 constants
    ```

Example: Bytecode for local variables in nested scopes
    When compiling:
    ```
    {
        var x = 1;
        {
            var a = 2;
            var b = 3;
        }
        var y = 4;
    }
    ```
    # 0000 -> x is created
    # 0002 -> a is created
    # 0004 -> b is created
    # 0006 -> a and b are discared using OP_POPN
    # 0008 -> y is created
    # 0010 -> x and y are discared using OP_POPN
    Then the bytecode looks like:
    ```
    == <script> ==
    0000    2 OP_CONSTANT           0   # 1
    0002    4 OP_CONSTANT           1   # 2
    0004    5 OP_CONSTANT           2   # 3
    0006    6 OP_POPN               2
    0008    7 OP_CONSTANT           3   # 4
    0010    8 OP_POPN               2
    0012    | OP_NIL
    0013    | OP_RETURN
    8 opcodes (14 bytes), 4 constants
    ```
