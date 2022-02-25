Feature: Variables | Globals

Example: Defining a local variable with initializing expression
    When running a clox file:
    ```
    {
        var local = 1 + 1;
        print local;
    }
    ```
    Then clox prints to stdout:
    ```
    2
    ```

Example: Defining a local variable without initializing expression
    When running a clox file:
    ```
    {
        var local;
        print local;
    }
    ```
    Then clox prints to stdout:
    ```
    nil
    ```

Example: Redefining a local variable in the same scope
    When running a clox file:
    ```
    {
        var local;
        var local;
    }
    ```
    Then clox fails with:
    ```
    [line 3] Error at 'local': Already a variable with this name in this scope.
    ```

Example: Reassigning a local variable
    When running a clox file:
    ```
    {
        var int = 1;
        int = 2;
        int = 3;
        print int;
    }
    ```
    Then clox prints to stdout:
    ```
    3
    ```

Example: Shadowing of local variables
    When running a clox file:
    ```
    {
        var local = 1;
        {
            var local = 2;
            {
                var local = 3;
                print local;        
            }
            print local;
        }
        print local;
    }
    ```
    Then clox prints to stdout:
    ```
    3
    2
    1
    ```

Example: Shadowing a global with a local variable
    When running a clox file:
    ```
    var x = "a";
    {
        var x = "b";
        print x;
    }
    print x;
    ```
    Then clox prints to stdout:
    ```
    "b"
    "a"
    ```

Example: Using a local that has gone out of scope
    When running a clox file:
    ```
    {
        var local;
    }
    print local;
    ```
    Then clox fails with:
    ```
    Undefined variable 'local'
    [line 4] in script
    ```

Example: 'Defining too many locals'
    When running a clox file:
    ```
    {
        var a0 = 0; var a1 = 1; var a2 = 2; var a3 = 3; var a4 = 4; var a5 = 5; var a6 = 6; var a7 = 7; var a8 = 8; var a9 = 9;
        var b0 = 0; var b1 = 1; var b2 = 2; var b3 = 3; var b4 = 4; var b5 = 5; var b6 = 6; var b7 = 7; var b8 = 8; var b9 = 9;
        var c0 = 0; var c1 = 1; var c2 = 2; var c3 = 3; var c4 = 4; var c5 = 5; var c6 = 6; var c7 = 7; var c8 = 8; var c9 = 9;
        var d0 = 0; var d1 = 1; var d2 = 2; var d3 = 3; var d4 = 4; var d5 = 5; var d6 = 6; var d7 = 7; var d8 = 8; var d9 = 9;
        var e0 = 0; var e1 = 1; var e2 = 2; var e3 = 3; var e4 = 4; var e5 = 5; var e6 = 6; var e7 = 7; var e8 = 8; var e9 = 9;
        var f0 = 0; var f1 = 1; var f2 = 2; var f3 = 3; var f4 = 4; var f5 = 5; var f6 = 6; var f7 = 7; var f8 = 8; var f9 = 9;
        var g0 = 0; var g1 = 1; var g2 = 2; var g3 = 3; var g4 = 4; var g5 = 5; var g6 = 6; var g7 = 7; var g8 = 8; var g9 = 9;
        var h0 = 0; var h1 = 1; var h2 = 2; var h3 = 3; var h4 = 4; var h5 = 5; var h6 = 6; var h7 = 7; var h8 = 8; var h9 = 9;
        var i0 = 0; var i1 = 1; var i2 = 2; var i3 = 3; var i4 = 4; var i5 = 5; var i6 = 6; var i7 = 7; var i8 = 8; var i9 = 9;
        var j0 = 0; var j1 = 1; var j2 = 2; var j3 = 3; var j4 = 4; var j5 = 5; var j6 = 6; var j7 = 7; var j8 = 8; var j9 = 9;
        var k0 = 0; var k1 = 1; var k2 = 2; var k3 = 3; var k4 = 4; var k5 = 5; var k6 = 6; var k7 = 7; var k8 = 8; var k9 = 9;
        var l0 = 0; var l1 = 1; var l2 = 2; var l3 = 3; var l4 = 4; var l5 = 5; var l6 = 6; var l7 = 7; var l8 = 8; var l9 = 9;
        var m0 = 0; var m1 = 1; var m2 = 2; var m3 = 3; var m4 = 4; var m5 = 5; var m6 = 6; var m7 = 7; var m8 = 8; var m9 = 9;
        var n0 = 0; var n1 = 1; var n2 = 2; var n3 = 3; var n4 = 4; var n5 = 5; var n6 = 6; var n7 = 7; var n8 = 8; var n9 = 9;
        var o0 = 0; var o1 = 1; var o2 = 2; var o3 = 3; var o4 = 4; var o5 = 5; var o6 = 6; var o7 = 7; var o8 = 8; var o9 = 9;
        var p0 = 0; var p1 = 1; var p2 = 2; var p3 = 3; var p4 = 4; var p5 = 5; var p6 = 6; var p7 = 7; var p8 = 8; var p9 = 9;
        var q0 = 0; var q1 = 1; var q2 = 2; var q3 = 3; var q4 = 4; var q5 = 5; var q6 = 6; var q7 = 7; var q8 = 8; var q9 = 9;
        var r0 = 0; var r1 = 1; var r2 = 2; var r3 = 3; var r4 = 4; var r5 = 5; var r6 = 6; var r7 = 7; var r8 = 8; var r9 = 9;
        var s0 = 0; var s1 = 1; var s2 = 2; var s3 = 3; var s4 = 4; var s5 = 5; var s6 = 6; var s7 = 7; var s8 = 8; var s9 = 9;
        var t0 = 0; var t1 = 1; var t2 = 2; var t3 = 3; var t4 = 4; var t5 = 5; var t6 = 6; var t7 = 7; var t8 = 8; var t9 = 9;
        var u0 = 0; var u1 = 1; var u2 = 2; var u3 = 3; var u4 = 4; var u5 = 5; var u6 = 6; var u7 = 7; var u8 = 8; var u9 = 9;
        var v0 = 0; var v1 = 1; var v2 = 2; var v3 = 3; var v4 = 4; var v5 = 5; var v6 = 6; var v7 = 7; var v8 = 8; var v9 = 9;
        var w0 = 0; var w1 = 1; var w2 = 2; var w3 = 3; var w4 = 4; var w5 = 5; var w6 = 6; var w7 = 7; var w8 = 8; var w9 = 9;
        var x0 = 0; var x1 = 1; var x2 = 2; var x3 = 3; var x4 = 4; var x5 = 5; var x6 = 6; var x7 = 7; var x8 = 8; var x9 = 9;
        var y0 = 0; var y1 = 1; var y2 = 2; var y3 = 3; var y4 = 4; var y5 = 5; var y6 = 6; var y7 = 7; var y8 = 8; var y9 = 9;
        var z0 = 0; var z1 = 1; var z2 = 2; var z3 = 3; var z4 = 4; var z5 = 5; var z6 = 6; var z7 = 7; var z8 = 8; var z9 = 9;
    }
    ```
    Then clox fails with:
    ```
    [line 27] Error at 'z6': Too many local variables in function.
    [line 27] Error at 'z7': Too many local variables in function.
    [line 27] Error at 'z8': Too many local variables in function.
    [line 27] Error at 'z9': Too many local variables in function.
    ```