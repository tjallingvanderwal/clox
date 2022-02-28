Feature: Variables | Constants

Example: Declaring a constant with literal initializing expression
    When running a clox file:
    ```
    {
        const constant = 1;
        print constant;
    }
    ```
    Then clox prints to stdout:
    ```
    1
    ```

Example: Declaring a constant with non-literal initializing expression
    When running a clox file:
    ```
    {
        const x = 1;
        const y = 2;
        const z = x + y;
        print z;
    }
    ```
    Then clox prints to stdout:
    ```
    3
    ```

Example: Declaring a constant without initializing expression
    When running a clox file:
    ```
    {
        const constant;
    }
    ```
    Then clox fails with:
    ```
    [line 2] Error at ';': Expect expresion to initialize constant.
    ```

Example: Assigning to a constant
    When running a clox file:
    ```
    {
        const constant = 1;
        constant = 2;
    }
    ```
    Then clox fails with:
    ```
    [line 3] Error at '=': Constant cannot be assigned to.
    ```

Example: Declaring a constant with an existing name
    When running a clox file:
    ```
    {
        const constant = 1;
        const constant = 2;
    }
    ```
    Then clox fails with:
    ```
    [line 3] Error at 'constant': Already a variable or constant with this name in this scope.
    ```

Example: A constant cannot be declared at the global level
    When running a clox file:
    ```
    const constant = 1;
    ```
    Then clox fails with:
    ```
    [line 1] Error at ';': Constants not allowed at global level.
    ```