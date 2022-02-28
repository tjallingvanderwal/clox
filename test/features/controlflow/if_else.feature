Feature: Control Flow | If Else

Example: The if-branch is executed when the condition is true
    When running a clox file:
    ```
    if (true){
        print 1;
    }
    else {
        print 2;
    }
    ```
    Then clox prints to stdout:
    ```
    1
    ```

Example: The else-branch is executed when the condition is false
    When running a clox file:
    ```
    if (false){
        print 1;
    }
    else {
        print 2;
    }
    ```
    Then clox prints to stdout:
    ```
    2
    ```    