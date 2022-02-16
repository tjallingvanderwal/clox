Feature: Comparison | "==" equality operator

Scenario: Numbers
    When evaluating "1 == 1"
    Then the result is "true"
    When evaluating "2 == 1"
    Then the result is "false" 

Example: Booleans
    When evaluating "true == true"
    Then the result is "true"
    When evaluating "true == false"
    Then the result is "false" 

Example: Nil
    When evaluating "nil == nil"
    Then the result is "true" 

Example: Strings
    When evaluating "'abc' == 'abc'"
    Then the result is "true"
    When evaluating "'abc' == 'a'"
    Then the result is "false"
    When evaluating "'abc' == 'def'"
    Then the result is "false" 

Example: Mixed Types: Boolean/Nil
    When evaluating "true == nil"
    Then the result is "false" 
    When evaluating "false == nil"
    Then the result is "false" 

Example: Mixed Types: Number/Nil
    When evaluating "0 == nil"
    Then the result is "false" 
    When evaluating "1 == nil"
    Then the result is "false" 

Example: Mixed Types: Number/Boolean
    When evaluating "0 == nil"
    Then the result is "false" 
    When evaluating "1 == nil"
    Then the result is "false" 

Example: Mixed Types: Number/String
    When evaluating "0 == '0'"
    Then the result is "false" 
