Feature: Constants | Numbers

Example: OP_CONSTANT is used to load a Number constant
    When compiling "2"
    Then the bytecode looks like:
        ```
        == code ==
        0000    1 OP_CONSTANT           0   # 2
        0002    | OP_RETURN       
        2 opcodes (3 bytes), 1 constants
        ```
        
