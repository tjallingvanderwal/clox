Feature: Variables | Globals

Example: Defining a global variable with initializing expression
    When running a clox file:
    ```
    var global = 1 + 1;
    print global;
    ```
    Then clox prints to stdout:
    ```
    2
    ```

Example: Defining a global variable without initializing expression
    When running a clox file:
    ```
    var global;
    print global;
    ```
    Then clox prints to stdout:
    ```
    nil
    ```

Example: Defining multiple global variables
    When running a clox file:
    ```
    var beverage = "cafe au lait";
    var breakfast = "beignets with " + beverage;
    print breakfast;
    ```
    Then clox prints to stdout:
    ```
    "beignets with cafe au lait"
    ```
