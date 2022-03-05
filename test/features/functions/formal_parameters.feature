Feature: Functions | Formal Parameters

Example: Declare a function with zero formal parameters
    When running a clox file:
    ```
    fun sayHi(){
        print "Hi";
    }
    print sayHi;
    ```
    Then clox prints to stdout:
    ```
    <fn sayHi(0)>
    ```

Example: Declare a function with 3 formal parameters
    When running a clox file:
    ```
    fun sayHi(a, b, c){
        print "Hi";
    }
    print sayHi;
    ```
    Then clox prints to stdout:
    ```
    <fn sayHi(3)>
    ```