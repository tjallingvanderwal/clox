Feature: Variables | Globals

Example: Defining a global variable with initializing expression
    When running a clox file:
    ```
    var global = 1 + 1;
    print 2;
    ```
    Then clox prints to stdout:
    ```
    2
    ```

Example: Defining a global variable without initializing expression
    When running a clox file:
    ```
    var global;
    print nil;
    ```
    Then clox prints to stdout:
    ```
    nil
    ```