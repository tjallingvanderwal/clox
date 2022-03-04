Feature: Command Line | --memory

Example: --memory shows allocated objects during every step of execution
    When running clox with "--file features/commandline/test.lox --memory"
    Then clox prints to stdout:
    ```
    == execution ==
            stack: [ <script> ]
            heap : [ <String "c"> ][ <String "b"> ][ <String "a"> ][ <script> ]
    0000    1 OP_CONSTANT           0   # "a"
            stack: [ <script> ][ "a" ]
            heap : [ <String "c"> ][ <String "b"> ][ <String "a"> ][ <script> ]
    0002    | OP_CONSTANT           1   # "b"
            stack: [ <script> ][ "a" ][ "b" ]
            heap : [ <String "c"> ][ <String "b"> ][ <String "a"> ][ <script> ]
    0004    | OP_ADD          
            stack: [ <script> ][ "ab" ]
            heap : [ <String "ab"> ][ <String "c"> ][ <String "b"> ][ <String "a"> ][ <script> ]
    0005    | OP_CONSTANT           2   # "c"
            stack: [ <script> ][ "ab" ][ "c" ]
            heap : [ <String "ab"> ][ <String "c"> ][ <String "b"> ][ <String "a"> ][ <script> ]
    0007    | OP_ADD          
            stack: [ <script> ][ "abc" ]
            heap : [ <String "abc"> ][ <String "ab"> ][ <String "c"> ][ <String "b"> ][ <String "a"> ][ <script> ]
    0008    | OP_PRINT        

    == output ==
    "abc"
            stack: [ <script> ]
            heap : [ <String "abc"> ][ <String "ab"> ][ <String "c"> ][ <String "b"> ][ <String "a"> ][ <script> ]
    0009    2 OP_RETURN      
    ```