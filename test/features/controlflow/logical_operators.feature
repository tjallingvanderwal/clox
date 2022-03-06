Feature: Control Flow | Logical Operators

Example: 'and' evaluates its right operand when the left is true
    When running a clox file:
    ```
    fun left(){
        print 'lhs';
        return true;
    }
    fun right(){
        print 'rhs';
        return "right";
    }
    print left() and right();
    ```
    Then clox prints to stdout:
    ```
    "lhs"
    "rhs"
    "right"
    ```

Example: 'and' does not evaluate its right operand when the left is false
    When running a clox file:
    ```
    fun left(){
        print 'lhs';
        return false;
    }
    fun right(){
        print 'rhs';
        return 'right';
    }
    print left() and right();
    ```
    Then clox prints to stdout:
    ```
    "lhs"
    false
    ```

Example: 'or' evaluates its right operand when the left is false
    When running a clox file:
    ```
    fun left(){
        print 'lhs';
        return false;
    }
    fun right(){
        print 'rhs';
        return 'right';
    }
    print left() or right();
    ```
    Then clox prints to stdout:
    ```
    "lhs"
    "rhs"
    "right"
    ```

Example: 'or' does not evaluate its right operand when the left is true
    When running a clox file:
    ```
    fun left(){
        print 'lhs';
        return true;
    }
    fun right(){
        print 'rhs';
        return 'right';
    }
    print left() or right();
    ```
    Then clox prints to stdout:
    ```
    "lhs"
    true
    ```