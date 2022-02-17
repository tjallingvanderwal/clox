Feature: Strings | Equality

Example: Two literals are (un)equal to each other
    When evaluating "'abc' == 'abc'"
    Then the result is "true"
    When evaluating "'abc' == 'def'"
    Then the result is "false"

Example: The result of a concatenation is equal to a literal
    When evaluating "'a'+'b' == 'ab'"
    Then the result is "true"
