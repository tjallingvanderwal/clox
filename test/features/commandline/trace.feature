Feature: Command Line | --trace

Example: --trace shows every step of execution
    When running clox with "--eval 'print 1 + 2;' --trace"
    Then clox prints to stdout:
    ```
    == execution ==
            stack: <empty>
    0000    1 OP_CONSTANT           0   # 1
            stack: [ 1 ]
    0002    | OP_CONSTANT           1   # 2
            stack: [ 1 ][ 2 ]
    0004    | OP_ADD          
            stack: [ 3 ]
    0005    | OP_PRINT        

    == output ==
    3
            stack: <empty>
    0006    | OP_RETURN
    ```

Example: When combined with --no-run
    When running clox with "--no-run --trace"
    Then clox fails with:
    ```
    Combining --trace with --no-run makes no sense.
    ```           
