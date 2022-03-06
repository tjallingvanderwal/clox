Feature: Strings | Interning

Example: Two identical literals point to the same ObjString object
    When running a clox file with options "--memory":
    ```
    "a" + "a";
    ```
    # Note how there is only 1 String "a" on the heap,
    # even though there are two literals in the source.
    Then clox prints to stdout:
    ```
    == execution ==
            stack: [ <script> ]
            heap : [ <String "a"> ][ <script> ]
    0000    1 OP_CONSTANT           0   # "a"
            stack: [ <script> ][ "a" ]
            heap : [ <String "a"> ][ <script> ]
    0002    | OP_CONSTANT           1   # "a"
            stack: [ <script> ][ "a" ][ "a" ]
            heap : [ <String "a"> ][ <script> ]
    0004    | OP_ADD
            stack: [ <script> ][ "aa" ]
            heap : [ <String "aa"> ][ <String "a"> ][ <script> ]
    0005    | OP_POP
            stack: [ <script> ]
            heap : [ <String "aa"> ][ <String "a"> ][ <script> ]
    0006    | OP_NIL
            stack: [ <script> ][ nil ]
            heap : [ <String "aa"> ][ <String "a"> ][ <script> ]
    0007    | OP_RETURN
    ```

Example: The result of a concatenation is mapped to be the same ObjString as a literal
    When running a clox file with options "--memory":
    ```
    "a" + "a" == "aa";
    ```
    # Note how there is only 1 String "aa" on the heap.
    # The concatenation (OP_ADD) does not create a new object
    Then clox prints to stdout:
    ```
    == execution ==
            stack: [ <script> ]
            heap : [ <String "aa"> ][ <String "a"> ][ <script> ]
    0000    1 OP_CONSTANT           0   # "a"
            stack: [ <script> ][ "a" ]
            heap : [ <String "aa"> ][ <String "a"> ][ <script> ]
    0002    | OP_CONSTANT           1   # "a"
            stack: [ <script> ][ "a" ][ "a" ]
            heap : [ <String "aa"> ][ <String "a"> ][ <script> ]
    0004    | OP_ADD
            stack: [ <script> ][ "aa" ]
            heap : [ <String "aa"> ][ <String "a"> ][ <script> ]
    0005    | OP_CONSTANT           2   # "aa"
            stack: [ <script> ][ "aa" ][ "aa" ]
            heap : [ <String "aa"> ][ <String "a"> ][ <script> ]
    0007    | OP_EQUAL
            stack: [ <script> ][ true ]
            heap : [ <String "aa"> ][ <String "a"> ][ <script> ]
    0008    | OP_POP
            stack: [ <script> ]
            heap : [ <String "aa"> ][ <String "a"> ][ <script> ]
    0009    | OP_NIL
            stack: [ <script> ][ nil ]
            heap : [ <String "aa"> ][ <String "a"> ][ <script> ]
    0010    | OP_RETURN
    ```
