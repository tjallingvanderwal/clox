Feature: Strings | Unclosed literals

Example: String with no end quote
    When evaluating "'string"
    Then the script fails with "Error: Unterminated string"
