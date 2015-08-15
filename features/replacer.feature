Feature: Replacer

  Scenario: Show version
    When I successfully run `replacer version`
    Then the output should contain "replacer version "
