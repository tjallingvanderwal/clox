Feature: Constants | Nil, True and False

Example: OP_NIL is used to load Nil
    When compiling "nil"
    Then the bytecode looks like:
        ```
        == code ==
        0000    1 OP_NIL
        0001    | OP_RETURN       
        2 opcodes (2 bytes), 0 constants
        ```

Example: OP_TRUE is used to load True
    When compiling "true"
    Then the bytecode looks like:
        ```
        == code ==
        0000    1 OP_TRUE
        0001    | OP_RETURN       
        2 opcodes (2 bytes), 0 constants
        ```

Example: OP_FALSE is used to load False
    When compiling "false"
    Then the bytecode looks like:
        ```
        == code ==
        0000    1 OP_FALSE
        0001    | OP_RETURN       
        2 opcodes (2 bytes), 0 constants
        ```