Feature: Control Flow | For

Example: The loop is repeated while the condition is true
    When running a clox file:
    ```
    for (var x = 1; x < 4; x = x + 1){
        print x;
    }
    ```
    Then clox prints to stdout:
    ```
    1
    2
    3
    ```

Example: A nested loop
    When running a clox file:
    ```
    for (var x = 1; x < 4; x = x + 1){
        for (var y = 1; y < 4; y = y + 1){
            print x * y;
        }
    }
    ```
    Then clox prints to stdout:
    ```
    1
    2
    3
    2
    4
    6
    3
    6
    9
    ```

Example: Syntax error: missing '(' after 'for'
    When running a clox file:
    ```
    for var x = 0; x < 4; x = x + 1) {

    }
    ```
    Then clox fails with:
    ```
    [line 1] Error at 'var': Expect '(' after 'for'.
    ```

Example: Semantic error: const in the initializer
    When running a clox file:
    ```
    for (const x = 0; x < 4; x = x + 1){}
    ```
    Then clox fails with:
    ```
    [line 1] Error at 'const': Cannot declare a constant in the initializer of a for loop.
    ```

Example: Syntax error: missing ';' after condition
    When running a clox file:
    ```
    for (var x = 0; x < 4){}
    ```
    Then clox fails with:
    ```
    [line 1] Error at ')': Expect ';' after loop condition.
    ```

Example: Syntax error: missing ')' after increment
    When running a clox file:
    ```
    for (var x = 0; x < 4; x = x + 1 {

    }
    ```
    Then clox fails with:
    ```
    [line 1] Error at '{': Expect ')' after for clauses.
    ```
