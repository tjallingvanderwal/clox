Feature: Constants | Nil, True and False

Example: OP_NIL is used to load Nil
    When compiling "nil"
    Then the bytecode looks like:
        ```
        == <script> ==
        0000    1 OP_NIL
        0001    | OP_POP
        0002    | OP_NIL
        0003    | OP_RETURN
        4 opcodes (4 bytes), 0 constants
        ```

Example: OP_TRUE is used to load True
    When compiling "true"
    Then the bytecode looks like:
        ```
        == <script> ==
        0000    1 OP_TRUE
        0001    | OP_POP
        0002    | OP_NIL
        0003    | OP_RETURN
        4 opcodes (4 bytes), 0 constants
        ```

Example: OP_FALSE is used to load False
    When compiling "false"
    Then the bytecode looks like:
        ```
        == <script> ==
        0000    1 OP_FALSE
        0001    | OP_POP
        0002    | OP_NIL
        0003    | OP_RETURN
        4 opcodes (4 bytes), 0 constants
        ```