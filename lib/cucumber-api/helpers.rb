module CucumberApi
  module Helpers
    # Bind grabbed values into placeholders in given URL
    # Ex: http://example.com?id={id} with {id => 1} becomes http://example.com?id=1
    # @param url [String] parameterized URL with placeholders
    # @return [String] binded URL or original URL if no placeholders
    def resolve url
      url.gsub!(/\{([a-zA-Z0-9_]+)\}/) do |s|
        s.gsub!(/[\{\}]/, '')
        if instance_variable_defined?("@#{s}")
          instance_variable_get("@#{s}")
        else
          raise 'Did you forget to "grab" ' + s + '?'
        end
      end
      url
    end
  end
end

World(CucumberApi::Helpers)
