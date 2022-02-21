Feature: Comparison | ">=" greater-or-equal-to operator

Example: Comparing Numbers with each other
    When evaluating "2 >= 1"
    Then the result is "true"
    When evaluating "2 >= 2"
    Then the result is "true"
    When evaluating "1 >= 2"
    Then the result is "false"

Example: Non-Numbers
    When evaluating "true >= false"
    Then the script fails with "Operands must be numbers."
    When evaluating "nil >= false"
    Then the script fails with "Operands must be numbers."
    When evaluating "3 >= nil"
    Then the script fails with "Operands must be numbers."
    When evaluating "3 >= '3'"
    Then the script fails with "Operands must be numbers."

Example: Bytecode for a>=b is !(a<b)
    When compiling "2 >= 1"
    Then the bytecode looks like:
        ```
        == code ==
        0000    1 OP_CONSTANT           0   # 2
        0002    | OP_CONSTANT           1   # 1
        0004    | OP_LESS         
        0005    | OP_NOT
        0006    | OP_POP          
        0007    | OP_RETURN       
        6 opcodes (8 bytes), 2 constants
        ```
