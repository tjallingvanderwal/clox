Feature: Arithmetic | "!"  not operator

Example: Flips a boolean
    When evaluating "!true"
    Then the result is "false"
    When evaluating "!false"
    Then the result is "true"
    When evaluating "!!false"
    Then the result is "false"
    
Example: Non-Numbers
    When evaluating "!4"
    Then the result is "false"
    When evaluating "!'xyz'"
    Then the result is "false"
    When evaluating "!nil"
    Then the result is "true"

# This example does not actually test what it says.
# But it checks that the stack looks normal, despite the optimalization. 
Example: The stack is modified in-place
    When evaluating "true == !!false" with tracing
    Then clox prints to stdout:
    ```
    == execution ==
            stack: <empty>
    0000    1 OP_TRUE         
            stack: [ true ]
    0001    | OP_FALSE        
            stack: [ true ][ false ]
    0002    | OP_NOT          
            stack: [ true ][ true ]
    0003    | OP_NOT          
            stack: [ true ][ false ]
    0004    | OP_EQUAL        
            stack: [ false ]
    0005    | OP_RETURN       

    == result ==
    false
    ```