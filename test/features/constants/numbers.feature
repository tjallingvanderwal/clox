Feature: Constants | Numbers

Example: OP_CONSTANT is used to load a Number constant
    When compiling "2"
    Then the bytecode looks like:
        ```
        == <script> ==
        0000    1 OP_CONSTANT           0   # 2
        0002    | OP_POP
        0003    | OP_NIL
        0004    | OP_RETURN                
        4 opcodes (5 bytes), 1 constants
        ```
        
