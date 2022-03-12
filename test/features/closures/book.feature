Feature: Closures | Examples from the book

# Chapter 25 Intro
Example: A nested function captures a local from a surrounding fuction
    When running a clox file:
    ```
    var x = "global";
    fun outer(){
        var x = "outer";
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
    "outer"
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
    Then clox prints to stdout:
    ```
    "local"
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
    Then clox prints to stdout:
    ```
    "doughnut"
    "bagel"
    ```

# Chapter 25.2
Example: Assigning to the captured variable
    When running a clox file:
    ```
    fun outer(){
        var x = 1;
        x = 2;

        fun inner(){
            print x;
        }

        inner();
    }
    outer();
    ```
    Then clox prints to stdout:
    ```
    2
    ```

# Chapte 25.3
Example: Assigning to the captured variable in a function
    When running a clox file:
    ```
    fun outer(){
        var x = "before";
        fun inner(){
            x = "assigned";
        }
        inner();
        print x;
    }
    outer();
    ```
    Then clox prints to stdout:
    ```
    "assigned"
    ```

# Chapter 25.2.2 - flattening upvalues
Example: Referencing a closed over variables multiple scopes up
    When running a clox file:
    ```
    fun outer(){
        var x = "value";

        fun middle(){
            fun inner(){
                print x;
            }

            print "create inner closure";
            return inner;
        }

        print "return from outer";
        return middle;
    }

    var mid = outer();
    var in = mid();
    in();
    ```
    Then clox prints to stdout:
    ```
    "return from outer"
    "create inner closure"
    "value"
    ```


# Chapter 25.2.2 - flattening upvalues
Example: Disassembly of multiple nested functions
    When compiling:
    ```
    fun outer(){
        var a = 1;
        var b = 2;
        fun middle(){
            var c = 3;
            var d = 4;
            fun inner(){
                print a + c + b + d;
            }
        }
    }
    ```
    Then the bytecode looks like:
    ```
    == inner ==
    0000    8 OP_GET_UPVALUE        0
    0002    | OP_GET_UPVALUE        1
    0004    | OP_ADD
    0005    | OP_GET_UPVALUE        2
    0007    | OP_ADD
    0008    | OP_GET_UPVALUE        3
    0010    | OP_ADD
    0011    | OP_PRINT
    0012    9 OP_NIL
    0013    | OP_RETURN
    10 opcodes (14 bytes), 0 constants
    == middle ==
    0000    5 OP_CONSTANT           0   # 3
    0002    6 OP_CONSTANT           1   # 4
    0004    9 OP_CLOSURE            2   # <fn inner(0)>
    0006    |   upvalue 0
    0008    |   local 1
    0010    |   upvalue 1
    0012    |   local 2
    0014   10 OP_NIL
    0015    | OP_RETURN
    5 opcodes (16 bytes), 3 constants
    == outer ==
    0000    2 OP_CONSTANT           0   # 1
    0002    3 OP_CONSTANT           1   # 2
    0004   10 OP_CLOSURE            2   # <fn middle(0)>
    0006    |   local 1
    0008    |   local 2
    0010   11 OP_NIL
    0011    | OP_RETURN
    5 opcodes (12 bytes), 3 constants
    == <script> ==
    0000   11 OP_CLOSURE            1   # <fn outer(0)>
    0002    | OP_DEFINE_GLOBAL      0   # "outer"
    0004    | OP_NIL
    0005    | OP_RETURN
    4 opcodes (6 bytes), 2 constants
    ```

# Chapter 25.4.1
Example: A closure captures a variable, not a value
    When running a clox file:
    ```
    var globalSet;
    var globalGet;

    fun main(){
        var a = "initial";

        fun set(){ a = "updated"; }
        fun get(){ print a; }

        globalSet = set;
        globalGet = get;
    }

    main();
    globalSet();
    globalGet();
    ```
    Then clox prints to stdout:
    ```
    "updated"
    ```
