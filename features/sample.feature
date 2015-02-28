# https://github.com/HackerNews/API
Feature: Hacker News REST API validation

  Scenario: Verify top stories JSON schema
    When I send and accept JSON
    And I send a GET request to "https://hacker-news.firebaseio.com/v0/topstories.json?print=pretty"
    Then the response status should be "200"
    And the JSON response should follow "features/schemas/topstories.json"

  Scenario Outline: Verify item JSON schema
    When I send and accept JSON
    And I send a GET request to "https://hacker-news.firebaseio.com/v0/topstories.json?print=pretty"
    Then the response status should be "200"
    And the JSON response root should be array
    When I grab "$[0]" as "id"
    And I send a GET request to "https://hacker-news.firebaseio.com/v0/item/{id}.json" with:
      | print  |
      | pretty |
    Then the response status should be "200"
    And the JSON response root should be object
    And the JSON response should have <optionality> key "<key>" of type <value type>

    Examples:
      | key   | value type | optionality |
      | id    | numeric    | required    |
      | score | numeric    | required    |
      | url   | string     | optional    |
