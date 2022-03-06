Feature: Functions | Native Functions

Example: Can be printed
    When running a clox file:
    ```
    print clock;
    ```
    Then clox prints to stdout:
    ```
    <native fn>
    ```

Example: Fibonacci
    When running a clox file:
    ```
    fun fib(const n){
        if (n < 2) return n;
        return fib(n - 2) + fib(n - 1);
    }
    print fib(7);
    ```
    Then clox prints to stdout:
    ```
    13
    ```

@benchmark
Example: Fibonacci Benchmark
    When running a clox file:
    ```
    fun fib(const n){
        if (n < 2) return n;
        return fib(n - 2) + fib(n - 1);
    }

    var start = clock();
    print fib(35);
    print clock() - start;
    ```
