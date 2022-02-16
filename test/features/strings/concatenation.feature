Feature: Strings | "+" as concatenation operator

Example: Strings can be concatenated
    When evaluating "'st' + 'ri' + 'ng'"
    Then the result contains "string"

Example: An empty String can be appended to another String
    When evaluating "'prefix' + ''"
    Then the result contains "prefix"

Example: An empty String can be prepended to another String
    When evaluating "'' + 'postfix'"
    Then the result contains "postfix"

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