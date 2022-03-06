Feature: Arithmetic | "unary-"  negate operator

Example: Negates a number
    When evaluating "-4"
    Then the result is "-4"
    When evaluating "-(-3)"
    Then the result is "3"
    When evaluating "2 + -(-3)"
    Then the result is "5"
    
Example: Non-Numbers
    When evaluating "-true"
    Then the script fails with "Operand must be a number."
    When evaluating "-nil"
    Then the script fails with "Operand must be a number."
    When evaluating "-'xyz'"
    Then the script fails with "Operand must be a number."

# This example does not actually test what it says.
# But it checks that the stack looks normal, despite the optimalization. 
Example: The stack is modified in-place
    When evaluating "2 + -(-3)" with tracing
    Then clox prints to stdout:
    ```
    == execution ==
            stack: [ <script> ]
    0000    1 OP_CONSTANT           0   # 2
            stack: [ <script> ][ 2 ]
    0002    | OP_CONSTANT           1   # 3
            stack: [ <script> ][ 2 ][ 3 ]
    0004    | OP_NEGATE       
            stack: [ <script> ][ 2 ][ -3 ]
    0005    | OP_NEGATE       
            stack: [ <script> ][ 2 ][ 3 ]
    0006    | OP_ADD          
            stack: [ <script> ][ 5 ]
    0007    | OP_PRINT
    
    == output ==
    5
        
            stack: [ <script> ]
    0008    | OP_NIL
            stack: [ <script> ][ nil ]                    
    0009    | OP_RETURN          
    ```
