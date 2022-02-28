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

Example: The value of the condition is popped from the stack when the branches converge
    When compiling: 
    ```
    if (false){
        print 1;
    }
    else {
        print 2;
    }
    ```
    # 0013 -> value of the condition is popped
    Then the bytecode looks like:
    ```
    == code ==
    0000    1 OP_FALSE        
    0001    | OP_JUMP_IF_FALSE      1 -> 10
    0004    2 OP_CONSTANT           0   # 1
    0006    | OP_PRINT        
    0007    3 OP_JUMP               7 -> 13
    0010    5 OP_CONSTANT           1   # 2
    0012    | OP_PRINT        
    0013    6 OP_POP          
    0014    | OP_RETURN       
    9 opcodes (15 bytes), 2 constants
    ```