Feature: Control Flow | Logical Operators

Example: 'and' evaluates its right operand when the left is true
    When evaluating "true and false" with tracing
    # 0005 | OP_POP   -> LHS is discarded
    # 0006 | OP_FALSE -> RHS is evaluated
    Then clox prints to stdout:
    ```
    == execution ==
            stack: <empty>
    0000    1 OP_TRUE
            stack: [ true ]
    0001    | OP_DUP
            stack: [ true ][ true ]
    0002    | OP_JUMP_IF_FALSE 0002 -> 0007
            stack: [ true ]
    0005    | OP_POP
            stack: <empty>
    0006    | OP_FALSE
            stack: [ false ]
    0007    | OP_PRINT

    == output ==
    false

            stack: <empty>
    0008    | OP_RETURN
    ```

Example: 'and' does not evaluate its right operand when the left is false
    When evaluating "false and true" with tracing
    Then clox prints to stdout:
    ```
    == execution ==
            stack: <empty>
    0000    1 OP_FALSE
            stack: [ false ]
    0001    | OP_DUP
            stack: [ false ][ false ]
    0002    | OP_JUMP_IF_FALSE 0002 -> 0007
            stack: [ false ]
    0007    | OP_PRINT

    == output ==
    false

            stack: <empty>
    0008    | OP_RETURN
    ```

Example: 'or' evaluates its right operand when the left is false
    When evaluating "false or true" with tracing
    # 0008 | OP_POP  -> LHS is discarded
    # 0009 | OP_TRUE -> RHS is evaluated
    Then clox prints to stdout:
    ```
    == execution ==
          stack: <empty>
    0000    1 OP_FALSE
            stack: [ false ]
    0001    | OP_DUP
            stack: [ false ][ false ]
    0002    | OP_JUMP_IF_FALSE 0002 -> 0008
            stack: [ false ]
    0008    | OP_POP
            stack: <empty>
    0009    | OP_TRUE
            stack: [ true ]
    0010    | OP_PRINT

    == output ==
    true

            stack: <empty>
    0011    | OP_RETURN
    ```

Example: 'or' does not evaluate its right operand when the left is true
    When evaluating "true or false" with tracing
    Then clox prints to stdout:
    ```
    == execution ==
            stack: <empty>
    0000    1 OP_TRUE
            stack: [ true ]
    0001    | OP_DUP
            stack: [ true ][ true ]
    0002    | OP_JUMP_IF_FALSE 0002 -> 0008
            stack: [ true ]
    0005    | OP_JUMP          0005 -> 0010
            stack: [ true ]
    0010    | OP_PRINT

    == output ==
    true

            stack: <empty>
    0011    | OP_RETURN
    ```