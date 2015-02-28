require 'json'
require 'jsonpath'
require 'rest-client'

module CucumberApi

  # Extension of {RestClient::Response} with support for JSON path traversal and validation
  module Response

    include RestClient::Response

    # Create a Response with JSON path support
    # @param response [RestClient::Response] original response
    # @return [Response] self
    def self.create response
      result = response
      result.extend Response
      result
    end

    # Check if given JSON path exists
    # @param json_path [String] a valid JSON path expression
    # @param json [String] optional JSON from which to check JSON path, default to response body
    # @return [true, false] true if JSON path is valid and exists, false otherwise
    def has json_path, json=nil
      if json.nil?
        json = JSON.parse body
      end
      not JsonPath.new(json_path).on(json).empty?
    end

    # Retrieve value of the first JSON element with given JSON path
    # @param json_path [String] a valid JSON path expression
    # @param json [String] optional JSON from which to apply JSON path, default to response body
    # @return [Object] value of first retrieved JSON element in form of Ruby object
    # @raise [Exception] if JSON path is invalid or no matching JSON element found
    def get json_path, json=nil
      if json.nil?
        json = JSON.parse body
      end
      results = JsonPath.new(json_path).on(json)
      if results.empty?
        raise %/Expected json path '#{json_path}' not found\n#{log_response}/
      end
      results.first
    end

    # Retrieve value of the first JSON element with given JSON path as given type
    # @param json_path [String] a valid JSON path expression
    # @param type [String] required type, possible values are 'numeric', 'array', 'string', 'boolean', 'numeric_string'
    # or 'object'
    # @param json [String] optional JSON from which to apply JSON path, default to response body
    # @return [Object] value of first retrieved JSON element in form of given type
    # @raise [Exception] if JSON path is invalid or no matching JSON element found or matching element does not match
    # required type
    def get_as_type json_path, type, json=nil
      value = get json_path, json
      case type
        when 'numeric'
          valid = value.is_a? Numeric
        when 'array'
          valid = value.is_a? Array
        when 'string'
          valid = value.is_a? String
        when 'boolean'
          valid = !!value == value
        when 'numeric_string'
          valid = value.is_a?(Numeric) or value.is_a?(String)
        when 'object'
          valid = value.is_a? Hash
        else
          raise %/Invalid expected type '#{type}'/
      end

      unless valid
        raise %/Expect '#{json_path}' as a '#{type}' but was '#{value.class}'\n#{log_response}/
      end
      value
    end

    # Retrieve value of the first JSON element with given JSON path as given type, with nil value allowed
    # @param json_path [String] a valid JSON path expression
    # @param type [String] required type, possible values are 'numeric', 'array', 'string', 'boolean', 'numeric_string'
    # or 'object'
    # @param json [String] optional JSON from which to apply JSON path, default to response body
    # @return [Object] value of first retrieved JSON element in form of given type or nil
    # @raise [Exception] if JSON path is invalid or no matching JSON element found or matching element does not match
    # required type
    def get_as_type_or_null json_path, type, json=nil
      value = get json_path, json
      value.nil? ? value : get_as_type(json_path, type, json)
    end

    private
      def log_response
        if ENV['cucumber_api_verbose'] == 'true'
          JSON.pretty_generate(JSON.parse to_s)
        else
          ''
        end
      end
  end
end