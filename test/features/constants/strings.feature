Feature: Constants | Strings

Example: OP_CONSTANT is used to load a String constant
    When compiling "'xyz'"
    Then the bytecode looks like:
        ```
        == <script> ==
        0000    1 OP_CONSTANT           0   # "xyz"
        0002    | OP_POP
        0003    | OP_NIL
        0004    | OP_RETURN                
        4 opcodes (5 bytes), 1 constants
        ```