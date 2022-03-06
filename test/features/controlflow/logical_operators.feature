Feature: Control Flow | Logical Operators

Example: 'and' evaluates its right operand when the left is true
    When evaluating "true and false" with tracing
    # 0005 | OP_POP   -> LHS is discarded
    # 0006 | OP_FALSE -> RHS is evaluated
    Then clox prints to stdout:
    ```
    == execution ==
            stack: [ <script> ]
    0000    1 OP_TRUE
            stack: [ <script> ][ true ]
    0001    | OP_DUP
            stack: [ <script> ][ true ][ true ]
    0002    | OP_JUMP_IF_FALSE 0002 -> 0007
            stack: [ <script> ][ true ]
    0005    | OP_POP
            stack: [ <script> ]
    0006    | OP_FALSE
            stack: [ <script> ][ false ]
    0007    | OP_PRINT

    == output ==
    false

            stack: [ <script> ]
    0008    | OP_NIL
            stack: [ <script> ][ nil ]
    0009    | OP_RETURN
    ```

Example: 'and' does not evaluate its right operand when the left is false
    When evaluating "false and true" with tracing
    Then clox prints to stdout:
    ```
    == execution ==
            stack: [ <script> ]
    0000    1 OP_FALSE
            stack: [ <script> ][ false ]
    0001    | OP_DUP
            stack: [ <script> ][ false ][ false ]
    0002    | OP_JUMP_IF_FALSE 0002 -> 0007
            stack: [ <script> ][ false ]
    0007    | OP_PRINT

    == output ==
    false

            stack: [ <script> ]
    0008    | OP_NIL
            stack: [ <script> ][ nil ]
    0009    | OP_RETURN
    ```

Example: 'or' evaluates its right operand when the left is false
    When evaluating "false or true" with tracing
    # 0008 | OP_POP  -> LHS is discarded
    # 0009 | OP_TRUE -> RHS is evaluated
    Then clox prints to stdout:
    ```
    == execution ==
            stack: [ <script> ]
    0000    1 OP_FALSE
            stack: [ <script> ][ false ]
    0001    | OP_DUP
            stack: [ <script> ][ false ][ false ]
    0002    | OP_JUMP_IF_FALSE 0002 -> 0008
            stack: [ <script> ][ false ]
    0008    | OP_POP
            stack: [ <script> ]
    0009    | OP_TRUE
            stack: [ <script> ][ true ]
    0010    | OP_PRINT

    == output ==
    true

            stack: [ <script> ]
    0011    | OP_NIL
            stack: [ <script> ][ nil ]
    0012    | OP_RETURN
    ```

Example: 'or' does not evaluate its right operand when the left is true
    When evaluating "true or false" with tracing
    Then clox prints to stdout:
    ```
    == execution ==
            stack: [ <script> ]
    0000    1 OP_TRUE
            stack: [ <script> ][ true ]
    0001    | OP_DUP
            stack: [ <script> ][ true ][ true ]
    0002    | OP_JUMP_IF_FALSE 0002 -> 0008
            stack: [ <script> ][ true ]
    0005    | OP_JUMP          0005 -> 0010
            stack: [ <script> ][ true ]
    0010    | OP_PRINT

    == output ==
    true

            stack: [ <script> ]
    0011    | OP_NIL
            stack: [ <script> ][ nil ]
    0012    | OP_RETURN        
    ```