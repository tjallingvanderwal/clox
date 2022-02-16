Feature: Constants | Strings

Example: OP_CONSTANT is used to load a String constant
    When compiling "'xyz'"
    Then the bytecode looks like:
        ```
        == code ==
        0000    1 OP_CONSTANT           0   # "xyz"
        0002    | OP_RETURN       
        2 opcodes (3 bytes), 1 constants
        ```