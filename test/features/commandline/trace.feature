Feature: Command Line | --trace

Example: --trace shows every step of execution
    When running clox with "--eval 'print 1 + 2;' --trace"
    Then clox prints to stdout:
    ```
    == execution ==
            stack: [ <script> ]
    0000    1 OP_CONSTANT           0   # 1
            stack: [ <script> ][ 1 ]
    0002    | OP_CONSTANT           1   # 2
            stack: [ <script> ][ 1 ][ 2 ]
    0004    | OP_ADD          
            stack: [ <script> ][ 3 ]
    0005    | OP_PRINT        

    == output ==
    3
            stack: [ <script> ]
    0006    | OP_NIL        
            stack: [ <script> ][ nil ]
    0007    | OP_RETURN
    ```

Example: When combined with --no-run
    When running clox with "--no-run --trace"
    Then clox fails with:
    ```
    Combining --trace with --no-run makes no sense.
    ```           
