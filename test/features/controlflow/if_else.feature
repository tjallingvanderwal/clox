Feature: Control Flow | If Else

Example: The if-branch is executed when the condition is true
    When running a clox file:
    ```
    if (true){
        print 1;
    }
    else {
        print 2;
    }
    ```
    Then clox prints to stdout:
    ```
    1
    ```

Example: The else-branch is executed when the condition is false
    When running a clox file:
    ```
    if (false){
        print 1;
    }
    else {
        print 2;
    }
    ```
    Then clox prints to stdout:
    ```
    2
    ```

Example: Code is generated for both branches when both are empty
    When compiling:
    ```
    if (false){
    }
    else {
    }
    ```
    Then the bytecode looks like:
    ```
    == <script> ==
    0000    1 OP_FALSE
    0001    | OP_JUMP_IF_FALSE 0001 -> 0007
    0004    2 OP_JUMP          0004 -> 0007
    0007    4 OP_NIL
    0008    | OP_RETURN
    5 opcodes (9 bytes), 0 constants
    ```

Example: No code is generated for the else-branch  when there is no else-branch
    When compiling:
    ```
    if (false){
    }
    ```
    Then the bytecode looks like:
    ```
    == <script> ==
    0000    1 OP_FALSE
    0001    | OP_JUMP_IF_FALSE      0001 -> 0004
    0004    2 OP_NIL
    0005    | OP_RETURN
    4 opcodes (6 bytes), 0 constants
    ```