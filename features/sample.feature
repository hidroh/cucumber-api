# https://github.com/HackerNews/API
Feature: Hacker News REST API validation

  Background:
    Given I send and accept JSON

  Scenario: Verify top stories JSON schema
    When I add Headers:
      | Cache-Control | no-cache |
    And I send a GET request to "https://hacker-news.firebaseio.com/v0/topstories.json?print=pretty"
    Then the response status should be "200"
    And the JSON response should follow "features/schemas/topstories.json"

  Scenario Outline: Verify item JSON schema
    When I send a GET request to "https://hacker-news.firebaseio.com/v0/topstories.json?print=pretty"
    Then the response status should be "200"
    And the JSON response root should be array
    When I grab "$[0]" as "id"
    And I send a GET request to "https://hacker-news.firebaseio.com/v0/item/{id}.json" with:
      | print  |
      | pretty |
    Then the response status should be "200"
    And the JSON response root should be object
    And the JSON response should have <optionality> key "<key>" of type <value type>
    And the JSON response should have "id" of type numeric and value "{id}"

    Examples:
      | key   | value type | optionality |
      | id    | numeric    | required    |
      | score | numeric    | required    |
      | url   | string     | optional    |

  Scenario: Demonstrate setting the JSON body with a docstring
    When I set JSON request body to:
    """
    {
      "title": "foo",
      "body":  "bar",
      "userId": 1
    }
    """
    And  I send a POST request to "http://jsonplaceholder.typicode.com/posts"
    Then the response status should be "201"
    And  the JSON response should have "id" of type numeric and value "101"
    And  the JSON response should have "title" of type string and value "foo"
    And  the JSON response should have "body" of type string and value "bar"
    And  the JSON response should have "userId" of type numeric and value "1"

