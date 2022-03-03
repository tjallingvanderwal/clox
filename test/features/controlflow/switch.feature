Feature: Control Flow | Switch

Example: Only the branch that matches the condition is executed
    When running a clox file:
    ```
    switch (3){
        case 1: print 'a';
        case 2: print 'b';
        case 3: print 'c';
    }
    ```
    Then clox prints to stdout:
    ```
    "c"
    ```

Example: The default branch is executed when no other branch matches
    When running a clox file:
    ```
    switch (4){
        case 1: print 'a';
        case 2: print 'b';
        case 3: print 'c';
        default: print 'x';
    }
    ```
    Then clox prints to stdout:
    ```
    "x"
    ```

Example: The 'default' branch is optional
    When running a clox file:
    ```
    switch (3){
        case 1: print 'a';
    }
    ```
    # Nothing happens
    Then clox prints to stdout:
    ```
    ```    

Example: The 'default' branch is executed when there are zero 'case'es
    When running a clox file:
    ```
    switch (3){
        default: print 'x';
    }
    ```
    Then clox prints to stdout:
    ```
    "x"
    ```        

Example: Local variables can be used inside cases
    When running a clox file:
    ```
    {   // make all vars locals
        var a = 1;
        var b = 2;
        switch (a){
            case 1: {
                var c = 3; // 'c' gets assigned call frame offset that contains copy of condition 
                var d = 4; // 'd' gets assigned call frame offset that contains '3' 
                print c;   
                print d;   
            }
        }
    }
    ```
    Then clox prints to stdout:
    ```
    1
    3
    ```

Example: Semantic error: Zero 'case'es and no 'default' branch
    When running a clox file:
    ```
    switch (nil){}
    ```
    Then clox fails with:
    ```
    [line 1] Error at '}': No 'case'es nor 'default' in 'switch'.
    ```

Example: Syntax error: Missing '('
    When running a clox file:
    ```
    switch nil){}
    ```
    Then clox fails with:
    ```
    [line 1] Error at 'nil': Expect '(' after 'switch'.
    ```    

Example: Syntax error: Missing ')'
    When running a clox file:
    ```
    switch (nil {}
    ```
    Then clox fails with:
    ```
    [line 1] Error at '{': Expect ')' after condition.
    ```    

Example: Syntax error: Missing '{'
    When running a clox file:
    ```
    switch (nil) }
    ```
    Then clox fails with:
    ```
    [line 1] Error at '}': Expect '{' to start list of cases.
    ```        

Example: Syntax error: Missing '}'
    When running a clox file:
    ```
    switch (nil) {
    ```
    Then clox fails with:
    ```
    [line 1] Error at end: Expect '}' to end list of cases.
    ```        

Example: Syntax error: Missing ':' after case expression
    When running a clox file:
    ```
    switch (nil) {
        case 1 print x;
    }
    ```
    Then clox fails with:
    ```
    [line 2] Error at 'print': Expect ':' after 'case' expression.
    ```            

Example: Syntax error: Missing ':' after default
    When running a clox file:
    ```
    switch (nil) {
        default print x;
    }
    ```
    Then clox fails with:
    ```
    [line 2] Error at 'print': Expect ':' after 'default'
    ```            