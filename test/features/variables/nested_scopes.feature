Feature: Variables | Nested scopes

@pending
Example: Local variables for nested scopes are popped in one go
    When compiling:
    ```
    {
        var x = 1;
        {
            var y = 2;
            var z = x + y;
        }
    }
    ```
    # FIXME
    # The POPN at 0009 and POP at 0011 should be coalesced into a single opcode.
    Then the bytecode looks like:
    ```
    == <script> ==
    0000    2 OP_CONSTANT           0   # 1
    0002    4 OP_CONSTANT           1   # 2
    0004    5 OP_GET_LOCAL          0
    0006    | OP_GET_LOCAL          1
    0008    | OP_ADD
    0009    6 OP_POPN               3
    0011    | OP_RETURN
    7 opcodes (11 bytes), 2 constants
    ```