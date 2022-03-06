Feature: Compiler | Stack Trace

Example: A stracktrace is printed when a runtime error occurrs
    When running a clox file:
    ```
    fun a(){
        b();
    }
    fun b(){
        c();
    }
    fun c(){
        d("too", "many", "args");
    }
    fun d(){

    }

    a();
    ```
    Then clox fails with:
    ```
    Expected 0 arguments but got 3.
    [line 8] in c()
    [line 5] in b()
    [line 2] in a()
    [line 14] in script
    ```