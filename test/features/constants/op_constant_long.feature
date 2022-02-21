Feature: Constants | OP_CONSTANT_LONG
        
Example: OP_CONSTANT_LONG is used when there are more than 4 constants
    When compiling "1 + '2' + 3 + '4' + 5 + '6'"
    Then the bytecode looks like:
        ```
        == code ==
        0000    1 OP_CONSTANT           0   # 1
        0002    | OP_CONSTANT           1   # "2"
        0004    | OP_ADD          
        0005    | OP_CONSTANT           2   # 3
        0007    | OP_ADD          
        0008    | OP_CONSTANT           3   # "4"
        0010    | OP_ADD          
        0011    | OP_CONSTANT_LONG      4   # 5
        0015    | OP_ADD          
        0016    | OP_CONSTANT_LONG      5   # "6"
        0020    | OP_ADD          
        0021    | OP_POP
        0022    | OP_RETURN         
        13 opcodes (23 bytes), 6 constants
        ```
