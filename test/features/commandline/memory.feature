Feature: Command Line | --memory

Example: --memory shows allocated objects during every step of execution
    When running clox with "--file features/commandline/test.lox --memory"
    Then clox prints to stdout:
    ```
    == execution ==
            stack: <empty>
            heap : [ <String "c"> ][ <String "b"> ][ <String "a"> ]
    0000    1 OP_CONSTANT           0   # "a"
            stack: [ "a" ]
            heap : [ <String "c"> ][ <String "b"> ][ <String "a"> ]
    0002    | OP_CONSTANT           1   # "b"
            stack: [ "a" ][ "b" ]
            heap : [ <String "c"> ][ <String "b"> ][ <String "a"> ]
    0004    | OP_ADD          
            stack: [ "ab" ]
            heap : [ <String "ab"> ][ <String "c"> ][ <String "b"> ][ <String "a"> ]
    0005    | OP_CONSTANT           2   # "c"
            stack: [ "ab" ][ "c" ]
            heap : [ <String "ab"> ][ <String "c"> ][ <String "b"> ][ <String "a"> ]
    0007    | OP_ADD          
            stack: [ "abc" ]
            heap : [ <String "abc"> ][ <String "ab"> ][ <String "c"> ][ <String "b"> ][ <String "a"> ]
    0008    2 OP_RETURN       

    == result ==
    "abc"
    ```