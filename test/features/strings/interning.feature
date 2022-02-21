Feature: Strings | Interning

Example: Two identical literals point to the same ObjString object
    When running a clox file with options "--memory":
    ```
    "a" + "a"
    ```
    # Note how there is only 1 String "a" on the heap,
    # even though there are two literals in the source.
    Then clox prints to stdout:
    ```
    == execution ==
            stack: <empty>
            heap : [ <String "a"> ]
    0000    1 OP_CONSTANT           0   # "a"
            stack: [ "a" ]
            heap : [ <String "a"> ]
    0002    | OP_CONSTANT           1   # "a"
            stack: [ "a" ][ "a" ]
            heap : [ <String "a"> ]
    0004    | OP_ADD          
            stack: [ "aa" ]
            heap : [ <String "aa"> ][ <String "a"> ]
    0005    | OP_RETURN       

    == result ==
    "aa"
    ```

Example: The result of a concatenation is mapped to be the same ObjString as a literal
    When running a clox file with options "--memory":
    ```
    "a" + "a" == "aa"
    ```
    # Note how there is only 1 String "aa" on the heap.
    # The concatenation (OP_ADD) does not create a new object
    Then clox prints to stdout:
    ```
    == execution ==
            stack: <empty>
            heap : [ <String "aa"> ][ <String "a"> ]
    0000    1 OP_CONSTANT           0   # "a"
            stack: [ "a" ]
            heap : [ <String "aa"> ][ <String "a"> ]
    0002    | OP_CONSTANT           1   # "a"
            stack: [ "a" ][ "a" ]
            heap : [ <String "aa"> ][ <String "a"> ]
    0004    | OP_ADD          
            stack: [ "aa" ]
            heap : [ <String "aa"> ][ <String "a"> ]
    0005    | OP_CONSTANT           2   # "aa"
            stack: [ "aa" ][ "aa" ]
            heap : [ <String "aa"> ][ <String "a"> ]
    0007    | OP_EQUAL        
            stack: [ true ]
            heap : [ <String "aa"> ][ <String "a"> ]
    0008    | OP_RETURN       

    == result ==
    true
    ```
