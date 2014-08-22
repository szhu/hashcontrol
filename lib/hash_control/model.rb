require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/hash_with_indifferent_access'
require_relative 'validator'

module HashControl
  # An hash-like type that requires certain keys to be defined
  module Model
    def initialize(hash = {})
      @hash = ::ActiveSupport::HashWithIndifferentAccess.new(hash)
      initialize_model if self.class.method_defined? :initialize_model
      hash_validator = validate_default
      validate(hash_validator) if self.class.method_defined? :validate
    end

    def symbolized_hash
      @hash.symbolize_keys
    end

    def slice(*keys)
      @symbolized_hash.select { |key, _| keys.include? key.to_sym }
    end

    private

    def validate_default
      hash_validator = Validator.new(@hash)
      hash_validator.require(*self.class.required_keys)
      unless self.class.permitted_keys == :all
        hash_validator.permit(*self.class.permitted_keys).only
      end
      hash_validator
    end

    module ClassMethods
      def initialize_class
        instance_variable_set(:@required_keys, Set.new)
        instance_variable_set(:@permitted_keys, Set.new)
      end
      attr_reader :required_keys, :permitted_keys

      def permit_all_keys
        @permitted_keys = :all
      end

      def require_key(*keys)
        keys.each { |key| key_accessor(key) }
        required_keys.merge keys
      end

      def permit_key(*keys)
        keys.each { |key| key_accessor(key) }
        permitted_keys.merge keys
      end

      def key_accessor(name)
        name = name.to_sym
        return if self.respond_to?(name)
        class_eval do
          define_method(name) { @hash[name] }
        end
      end
    end

    def [](name)
      @hash[name]
    end

    def self.included(base)
      base.extend ClassMethods
      base.initialize_class
    end
  end

  # Allow setting
  module WritableModel
    include Model

    module ClassMethods
      def key_accessor(name)
        name = name.to_sym
        return if self.respond_to?(name)
        class_eval do
          define_method(name) { @hash[name] }
          define_method("#{name}=") { |x| @hash[name] = x }
        end
      end
    end

    def []=(name, x)
      @hash[name] = x
    end

    def self.included(base)
      Model.included(base)
      base.extend ClassMethods
    end
  end

  # Add extra I/O
  # Placed in a separate block for sake of clarity
  module Model
    # JSON support
    module ClassMethods
      def json_create(hash_as_json)
        require 'json'
        hash = JSON.parse hash_as_json
        new hash
      end
    end

    def to_json
      require 'json'
      @hash.to_json
    end

    def as_json(_opts = {})
      symbolized_hash
    end

    # AwesomePrint support
    def ai(options)
      require 'awesome_print'
      AwesomePrint::Inspector.new(options).awesome(symbolized_hash)
    end
  end
end
