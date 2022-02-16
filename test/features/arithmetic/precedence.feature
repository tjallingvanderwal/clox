Feature: Arithmetic | Precendence of operators

Example: Without grouping
    When evaluating "1 + 2 * 3"
    Then the result is "7"
    When evaluating "2 * 2 + 3"
    Then the result is "7"

Example: With grouping
    When evaluating "(1 + 2) * 3"
    Then the result is "9"
    When evaluating "2 * (2 + 3)"
    Then the result is "10"
