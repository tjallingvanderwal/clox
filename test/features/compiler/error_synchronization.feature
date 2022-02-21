Feature: Compiler | Error Synchronization

Example: Multiple errors are reported
    When running a clox file:
    ```
    print "-------------"
    print "your ad here!"
    print "-------------"
    ```
    Then clox fails with:
    ```
    [line 2] Error at 'print': Expect ';' after value.
    [line 3] Error at 'print': Expect ';' after value.
    [line 3] Error at end: Expect ';' after value.
    ```

Example: Errors within the same statement are silenced
    When running a clox file:
    ```
    1 + + 3 + + 5; 3 /* 5;
    ```
    Then clox fails with:
    ```
    [line 1] Error at '+': Expect expression
    [line 1] Error at '*': Expect expression
    ```    