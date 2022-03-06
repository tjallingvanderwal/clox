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

Example: Declare a formal parameter as const
    When running a clox file:
    ```
    fun say(const greeting){
        print greeting;
    }
    print say("hi");
    ```
    Then clox prints to stdout:
    ```
    "hi"
    nil
    ```

Example: Semantic error: assigning to a formal parameter declared as const
    When running a clox file:
    ```
    fun say(const message){
        message = "something else";
    }
    ```
    Then clox fails with:
    ```
    [line 2] Error at '=': Constant cannot be assigned to.
    ```