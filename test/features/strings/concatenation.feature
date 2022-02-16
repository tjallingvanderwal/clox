Feature: Strings | "+" as concatenation operator

Example: Strings can be concatenated
    When evaluating "'st' + 'ri' + 'ng'"
    Then the result contains "string"

Example: Strings and other values cannot be concatenated to each other
    When evaluating "1 + 'x'"
    Then the script fails with "Operands must be two numbers or two strings."
    When evaluating "'x' + 1"
    Then the script fails with "Operands must be two numbers or two strings."
    When evaluating "nil + 'x'"
    Then the script fails with "Operands must be two numbers or two strings."
    When evaluating "'x' + nil"
    Then the script fails with "Operands must be two numbers or two strings."
    When evaluating "true + 'x'"
    Then the script fails with "Operands must be two numbers or two strings."
    When evaluating "'x' + true"
    Then the script fails with "Operands must be two numbers or two strings."