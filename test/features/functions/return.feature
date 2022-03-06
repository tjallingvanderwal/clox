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