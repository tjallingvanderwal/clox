Feature: Statements | Print

Example: Prints its argument to stdout
    When running a clox file:
    ```
    print "a" + "b" + "c";
    ```
    Then clox prints to stdout:
    ```
    "abc"
    ```