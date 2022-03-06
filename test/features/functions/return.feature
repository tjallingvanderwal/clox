Feature: Functions | Return statement

Example: Implicit return: Nil is returned
    When running a clox file:
    ```
    fun pointOf(){
        print "no return";
    }
    print pointOf();
    ```
    Then clox prints to stdout:
    ```
    "no return"
    nil
    ```

Example: Explicit return: value of expression is returned
    When running a clox file:
    ```
    fun sum(){
        return 1 + 2;
    }
    print sum();
    ```
    Then clox prints to stdout:
    ```
    3
    ```

Example: Return from top-level code is not allowed
    When running a clox file:
    ```
    return 1 + 2;
    ```
    Then clox fails with:
    ```
    [line 1] Error at 'return': Can't return from top-level code.
    ```

Example: Syntax error: missing ';'
    When running a clox file:
    ```
    fun sum(){
        return 1 + 2
    }
    ```
    Then clox fails with:
    ```
    [line 3] Error at '}': Expect ';' after return value.
    [line 3] Error at end: Expect '}' after block.
    ```