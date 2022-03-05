Feature: Functions | Syntax Errors

Example: Syntax error: missing '('
    When running a clox file:
    ```
    fun sayHi ){
        print "Hi";
    }
    print sayHi;
    ```
    Then clox fails with:
    ```
    [line 1] Error at ')': Expect '(' after function name.
    ```

Example: Syntax error: missing ')'
    When running a clox file:
    ```
    fun sayHi( {
        print "Hi";
    }
    print sayHi;
    ```
    Then clox fails with:
    ```
    [line 1] Error at '{': Expect parameter name.
    ```

Example: Syntax error: missing '{'
    When running a clox file:
    ```
    fun sayHi()
        print "Hi";
    }
    print sayHi;
    ```
    Then clox fails with:
    ```
    [line 2] Error at 'print': Expect '{' before function body.
    ```

Example: Syntax error: missing formal parameter name (1)
    When running a clox file:
    ```
    fun sayHi(,)
        print "Hi";
    }
    print sayHi;
    ```
    Then clox fails with:
    ```
    [line 1] Error at ',': Expect parameter name.
    ```

Example: Syntax error: missing formal parameter name (2)
    When running a clox file:
    ```
    fun sayHi(a, b, )
        print "Hi";
    }
    print sayHi;
    ```
    Then clox fails with:
    ```
    [line 1] Error at ')': Expect parameter name.
    ```