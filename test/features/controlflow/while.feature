Feature: Control Flow | While

Example: The loop is repeated while the condition is true
    When running a clox file:
    ```
    var x = 1;
    while (x < 4){
        print x;
        x = x + 1;
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
    var x = 1;
    while (x < 4){
        var y = 1;
        while (y < 4){
            print x * y;
            y = y + 1;
        }
        x = x + 1;
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