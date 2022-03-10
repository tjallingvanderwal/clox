Feature: Command Line | --memory

Example: --memory shows allocated objects during every step of execution
    When running clox with "--file features/commandline/test.lox --memory"
    Then clox prints to stdout:
    ```
    == execution ==
            stack: [ <script> ]
            heap : [ <script> ][ <String "c"> ][ <String "b"> ][ <String "a"> ][ <script> ][ <native fn> ][ <String "clock"> ]
    0000    1 OP_CONSTANT           0   # "a"
            stack: [ <script> ][ "a" ]
            heap : [ <script> ][ <String "c"> ][ <String "b"> ][ <String "a"> ][ <script> ][ <native fn> ][ <String "clock"> ]
    0002    | OP_CONSTANT           1   # "b"
            stack: [ <script> ][ "a" ][ "b" ]
            heap : [ <script> ][ <String "c"> ][ <String "b"> ][ <String "a"> ][ <script> ][ <native fn> ][ <String "clock"> ]
    0004    | OP_ADD
            stack: [ <script> ][ "ab" ]
            heap : [ <String "ab"> ][ <script> ][ <String "c"> ][ <String "b"> ][ <String "a"> ][ <script> ][ <native fn> ][ <String "clock"> ]
    0005    | OP_CONSTANT           2   # "c"
            stack: [ <script> ][ "ab" ][ "c" ]
            heap : [ <String "ab"> ][ <script> ][ <String "c"> ][ <String "b"> ][ <String "a"> ][ <script> ][ <native fn> ][ <String "clock"> ]
    0007    | OP_ADD
            stack: [ <script> ][ "abc" ]
            heap : [ <String "abc"> ][ <String "ab"> ][ <script> ][ <String "c"> ][ <String "b"> ][ <String "a"> ][ <script> ][ <native fn> ][ <String "clock"> ]
    0008    | OP_PRINT

    == output ==
    "abc"
            stack: [ <script> ]
            heap : [ <String "abc"> ][ <String "ab"> ][ <script> ][ <String "c"> ][ <String "b"> ][ <String "a"> ][ <script> ][ <native fn> ][ <String "clock"> ]
    0009    2 OP_NIL
            stack: [ <script> ][ nil ]
            heap : [ <String "abc"> ][ <String "ab"> ][ <script> ][ <String "c"> ][ <String "b"> ][ <String "a"> ][ <script> ][ <native fn> ][ <String "clock"> ]
    0010    | OP_RETURN
    ```