Feature: Variables | Globals

Example: Defining a global variable with initializing expression
    When running a clox file:
    ```
    var global = 1 + 1;
    print global;
    ```
    Then clox prints to stdout:
    ```
    2
    ```

Example: Defining a global variable without initializing expression
    When running a clox file:
    ```
    var global;
    print global;
    ```
    Then clox prints to stdout:
    ```
    nil
    ```

Example: Reassigning a global variable
    When running a clox file:
    ```
    var int = 1;
    int = 2;
    int = 3;
    print int;
    ```
    Then clox prints to stdout:
    ```
    3
    ```

Example: Making breakfast
    When running a clox file:
    ```
    var breakfast = "beignets";
    var beverage = "cafe au lait";
    breakfast = breakfast + " with " + beverage;
    print breakfast;
    ```
    Then clox prints to stdout:
    ```
    "beignets with cafe au lait"
    ```

# Each global requires 2 constants (name + value), so only 128 globals are needed to fill up the chunk.
Example: 'Defining too many globals'
    When running a clox file:
    ```
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
    var m0 = 0; var m1 = 1; var m2 = 2; var m3 = 3; var m4 = 4; var m5 = 5; var m6 = 6; var m7 = 7;
    var m8 = 8;
    var m9 = 9;
    ```
    Then clox fails with:
    ```
    [line 14] Error at 'm8': Too many constants in one chunk.
    [line 15] Error at 'm9': Too many constants in one chunk.
    ```