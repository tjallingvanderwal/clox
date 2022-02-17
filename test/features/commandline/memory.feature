Feature: Command Line | --memory

Example: --memory shows allocated objects during every step of execution
    When running clox with "--file features/commandline/test.lox --memory"
    Then clox prints to stdout:
    ```
    == execution ==
              stack: <empty>
              heap : [ <String(C) "c"> ][ <String(C) "b"> ][ <String(C) "a"> ]
    0000    1 OP_CONSTANT           0   # "a"
              stack: [ "a" ]
              heap : [ <String(C) "c"> ][ <String(C) "b"> ][ <String(C) "a"> ]
    0002    | OP_CONSTANT           1   # "b"
              stack: [ "a" ][ "b" ]
              heap : [ <String(C) "c"> ][ <String(C) "b"> ][ <String(C) "a"> ]
    0004    | OP_ADD          
              stack: [ "ab" ]
              heap : [ <String(O) "ab"> ][ <String(C) "c"> ][ <String(C) "b"> ][ <String(C) "a"> ]
    0005    | OP_CONSTANT           2   # "c"
              stack: [ "ab" ][ "c" ]
              heap : [ <String(O) "ab"> ][ <String(C) "c"> ][ <String(C) "b"> ][ <String(C) "a"> ]
    0007    | OP_ADD          
              stack: [ "abc" ]
              heap : [ <String(O) "abc"> ][ <String(O) "ab"> ][ <String(C) "c"> ][ <String(C) "b"> ][ <String(C) "a"> ]
    0008    2 OP_RETURN       

    == result ==
    "abc"
    ```