Feature: Closures | Examples from the book

# Chapter 25 Intro
Example: A nested function captures a local from a surrounding fuction
    When running a clox file:
    ```
    var x = "global";
    fun outer(){
        var x = "inner";
        fun inner(){
            print x;
        }
        inner();
    }
    outer();
    ```
    # output should be "inner" instead of "global"
    Then clox prints to stdout:
    ```
    "global"
    ```

# Chapter 25 Intro
Example: Returning a closure
    When running a clox file:
    ```
    fun makeClosure(){
        var local = "local";
        fun closure(){
            print local;
        }
        return closure;
    }
    var closure = makeClosure();
    closure();
    ```
    Then clox fails with:
    ```
    Undefined variable 'local'
    [line 4] in closure()
    [line 9] in script
    ```

# Chapter 25.1
Example: Making multiple closures from the same function
    When running a clox file:
    ```
    fun makeClosure(value){
        fun closure(){
            print value;
        }
        return closure;
    }
    var doughnut = makeClosure("doughnut");
    var bagel = makeClosure("bagel");
    doughnut();
    bagel();
    ```
    Then clox fails with:
    ```
    Undefined variable 'value'
    [line 3] in closure()
    [line 9] in script
    ```
