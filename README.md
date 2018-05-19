# cucumber-api
[![Build Status](https://travis-ci.org/hidroh/cucumber-api.svg?branch=master)](https://travis-ci.org/hidroh/cucumber-api) [![Gem Version](https://badge.fury.io/rb/cucumber-api.svg)](http://badge.fury.io/rb/cucumber-api) [![Dependency Status](https://gemnasium.com/hidroh/cucumber-api.svg)](https://gemnasium.com/hidroh/cucumber-api)
 [![Code Climate](https://codeclimate.com/github/hidroh/cucumber-api/badges/gpa.svg)](https://codeclimate.com/github/hidroh/cucumber-api) [![Total Downloads](http://ruby-gem-downloads-badge.herokuapp.com/cucumber-api?type=total)](https://rubygems.org/gems/cucumber-api)

API validator in BDD style with [Cucumber](https://cukes.info/). **cucumber-api** lets one validate public APIs JSON response in blazingly fast time.

Inspired by [cucumber-api-steps](https://github.com/jayzes/cucumber-api-steps).

Checkout [sample](/features/sample.feature) to see **cucumber-api** in action.

## Installation

Add `cucumber-api` gem to your `Gemfile`:

    gem 'cucumber-api'

Require `cucumber-api` in your Cucumber's `env.rb`:

```ruby
require 'cucumber-api'
```

## Configuration

**Verbose logging:** enable verbose logging of API calls and responses by setting `cucumber_api_verbose=true` in your `ENV`, preferably via your `cucumber.yml`

```yaml
# config/cucumber.yml
##YAML Template
---
verbose     : cucumber_api_verbose=true
```

## Usage

### Available steps

**Preparation steps**

Specify your request header's `Content-Type` and `Accept`. The only supported option for `Accept` is `application/json` at the moment.

```gherkin
Given I send and accept JSON
Given I send "(.*?)" and accept JSON
```

You could also others header's information like:

```gherkin
Given I send and accept JSON
And I add Headers:
  | name1 | value |
  | name2 | other |  
```

Specify POST body

```gherkin
When I set JSON request body to '(.*?)'
When I set form request body to:
  | key1 | value1              |
  | key2 | {value2}            |
  | key3 | file://path-to-file |
When I set JSON request body to:
"""
{
  "key1": "jsonString",
  "key2":  1
}
"""
```

Or from YAML/JSON file

```gherkin
When I set request body from "(.*?).(yml|json)"
```

Example:

```Gherkin
Given I send "www-x-form-urlencoded" and accept JSON
When I set JSON request body to '{"login": "email@example.com", "password": "password"}'
When I set form request body to:
  | login    | email@example.com     |
  | password | password              |
When I set request body from "data/json-data.json"
When I set request body from "data/form-data.yml"
```

**Request steps**

Specify query string parameters and send an HTTP request to given URL with parameters

```gherkin
When I send a (GET|POST|PATCH|PUT|DELETE) request to "(.*?)"
When I send a (GET|POST|PATCH|PUT|DELETE) request to "(.*?)" with:
  | param1 | param2 | ... |
  | value1 | value2 | ... |
```

Temporarily save values from the last request to use in subsequent steps in the same scenario:

```gherkin
When I grab "(.*?)" as "(.*?)"
```

Optionally, auto infer placeholder from grabbed JSON path:

```gherkin
# Grab and auto assign {id} as placeholder
When I grab "$..id"
```

The saved value can then be used to replace `{placeholder}` in the subsequent steps.

Example:

```gherkin
When I send a POST request to "http://example.com/token"
And I grab "$..request_token" as "token"
And I grab "$..access_type" as "type"
And I grab "$..id"
And I send a GET request to "http://example.com/{token}" with:
  | type            | pretty |
  | {type}          | true   |
Then the JSON response should have required key "id" of type string and value "{id}"
```

Assume that [http://example.com/token](http://example.com/token) have an element `{"request_token": 1, "access_type": "full", "id": "user1"}`, **cucumber-api** will execute the followings:

* POST [http://example.com/token](http://example.com/token)
* Extract the first `request_token`, `access_type` and `id` from JSON response and save it for subsequent steps
* GET [http://example.com/1?type=full&pretty=true](http://example.com/1?type=full&pretty=true)
* Verify that JSON response has a pair of JSON key-value: `"id": "user1"`
* Clear all saved values

This will be handy when one needs to make a sequence of calls to authenticate/authorize API access.

**Assert steps**

Verify:
* HTTP response status code
* JSON response against a JSON schema conforming to [JSON Schema Draft 4](http://tools.ietf.org/html/draft-zyp-json-schema-04)
* Adhoc JSON response key-value type pair, where key is a [JSON path](http://goessner.net/articles/JsonPath/)

```gherkin
Then the response status should be "(\d+)"
Then the JSON response should follow "(.*?)"
Then the JSON response root should be (object|array)
Then the JSON response should have key "([^\"]*)"
Then the JSON response should have (required|optional) key "(.*?)" of type (numeric|string|boolean|numeric_string|object|array|any)( or null)
Then the JSON response should have (required|optional) key "(.*?)" of type (numeric|string|boolean|numeric_string|object|array|any)( or null) and value "(.*?)"
```

Example:

```gherkin
Then the response status should be "200"
Then the JSON response should follow "features/schemas/example_all.json"
Then the JSON response root should be array
Then the JSON response should have key "id"
Then the JSON response should have optional key "format" of type string or null
Then the JSON response should have required key "status" of type string and value "foobar"
```

Also checkout [sample](/features/sample.feature) for real examples. Run sample with the following command:

```
cucumber -p verbose
```

### Response caching

Response caching is provided for GET requests by default. This is useful when you have a Scenario Outline or multiple Scenarios that make GET requests to the same endpoint.

Only the first request to that endpoint is made, subsequent requests will use cached response. Response caching is only available for GET method.

The response cache can also be cleared if needed:

```gherkin
Given I clear the response cache
```

## Dependencies
* [cucumber](https://github.com/cucumber/cucumber) for BDD style specs
* [jsonpath](https://github.com/joshbuddy/jsonpath) for traversal of JSON response via [JSON path](http://goessner.net/articles/JsonPath/)
* [json-schema](https://github.com/ruby-json-schema/json-schema) for JSON schema validation
* [rest-client](https://github.com/rest-client/rest-client) for HTTP REST request
