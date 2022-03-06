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
            stack: [ <script> ]
    0000    1 OP_TRUE
            stack: [ <script> ][ true ]
    0001    | OP_FALSE
            stack: [ <script> ][ true ][ false ]
    0002    | OP_NOT
            stack: [ <script> ][ true ][ true ]
    0003    | OP_NOT
            stack: [ <script> ][ true ][ false ]
    0004    | OP_EQUAL
            stack: [ <script> ][ false ]
    0005    | OP_PRINT

    == output ==
    false

            stack: [ <script> ]
    0006    | OP_NIL
            stack: [ <script> ][ nil ]
    0007    | OP_RETURN
    ```
