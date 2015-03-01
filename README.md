# cucumber-api
API validator in BBD style with [Cucumber](https://cukes.info/). **cucumber-api** lets one validate public APIs JSON response in blazingly fast time.

Inspired by [cucumber-api-steps](https://github.com/jayzes/cucumber-api-steps).

Checkout [sample](/features/sample.feature) to see **cucumber-api** in action.

## Installation

Add `cucumber-api` gem to your `Gemfile`:

    gem 'cucumber-api'

Require `cucumber-api` in your Cucumber's `env.rb`:

    require 'cucumber-api'

## Configuration

**Verbose logging:** enable verbose logging of API calls and responses by setting `cucumber_api_verbose=true` in your `ENV`, preferably via your `cucumber.yml`

    # config/cucumber.yml
    ##YAML Template
    ---
    verbose     : cucumber_api_verbose=true

## Usage

### Available steps

**Preparation steps**

Specify your request header's `Content-Type` and `Accept`. The only supported option for `Accept` is `application/json` at the moment.

    Given I send and accept JSON
    Given I send "(.*?)" and accept JSON
    When I set JSON request body to '(.*?)'

Example:

    Given I send "www-x-form-urlencoded" and accept JSON
    When I set JSON request body to '{"login": "email@example.com", "password": "password"}'

**Request steps**

Specify query string parameters and send an HTTP request to given URL with parameters

    When I send a (GET|POST|PATCH|PUT|DELETE) request to "(.*?)"
    When I send a (GET|POST|PATCH|PUT|DELETE) request to "(.*?)" with:
      | param1 | param2 | ... |
      | value1 | value2 | ... |

Temporarily save values from the last request to use in the next request in the same scenario:

    When I grab "(.*?)" as "(.*?)"

The saved value can then be used to replace `{placeholder}` in the next request.

Example:

    When I send a GET request to "http://example.com/all"
    And I grab "$..id" as "detail_id"
    And I grab "$..format" as "detail_format"
    And I send a GET request to "http://example.com/{detail_id} with:
      | format          | pretty |
      | {detail_format} | true   |

Assume that [http://example.com/all](http://example.com/all) have an element `{"id": 1, "format": "full"}`, **cucumber-api** will execute the followings:

* GET [http://example.com/all](http://example.com/all)
* Extract the first `id` and `format` from JSON response and save it for next request
* GET [http://example.com/1?format=full&pretty=true](http://example.com/1?format=full&pretty=true)
* Clear all saved values

**Assert steps**

Verify:
* HTTP response status code
* JSON response against a JSON schema conforming to [JSON Schema Draft 4](http://tools.ietf.org/html/draft-zyp-json-schema-04)
* Adhoc JSON response key-value type pair, where key is a [JSON path](http://goessner.net/articles/JsonPath/)

```
Then the response status should be "(\d+)"
Then the JSON response should follow "(.*?)"
Then the JSON response root should be (object|array)
Then the JSON response should have key "([^\"]*)"
Then the JSON response should have (required|optional) key "(.*?)" of type (numeric|string|array|boolean|numeric_string|object|array|any)( or null)
```

Example:

    Then the response status should be "200"
    Then the JSON response should follow "features/schemas/example_all.json"
    Then the JSON response root should be array
    Then the JSON response should have key "id"
    Then the JSON response should have optional key "format" of type string or null

Also checkout [sample](/features/sample.feature) for real examples.

### Response caching

Response caching is provided for GET requests by default. This is useful when you have a Scenario Outline or multiple Scenarios that make GET requests to the same endpoint.

Only the first request to that endpoint is made, subsequent requests will use cached response. Response caching is only available for GET method.

## Dependencies
* [cucumber](https://github.com/cucumber/cucumber) for BDD style specs
* [jsonpath](https://github.com/joshbuddy/jsonpath) for traversal of JSON response via [JSON path](http://goessner.net/articles/JsonPath/)
* [json-schema](https://github.com/ruby-json-schema/json-schema) for JSON schema validation
* [rest-client](https://github.com/rest-client/rest-client) for HTTP REST request