require 'active_support/hash_with_indifferent_access'
require 'active_support/inflector'
require 'set'

module HashControl
  class Validator
    def initialize(hash, opts = {})
      if hash.is_a? ::ActiveSupport::HashWithIndifferentAccess
        @hash = hash
      else
        @hash = ::ActiveSupport::HashWithIndifferentAccess.new(hash)
      end
      @error_class = opts[:raising] || ArgumentError
      @term = opts[:term] || 'param'
      @string_keys = opts[:string_keys] || false
      @permitted_keys = Set.new
    end

    # Specifies keys that must exist
    def require(*keys)
      permitted_keys.merge keys
      required_keys = keys.to_set
      unless (missing_keys = required_keys - hash_keys).empty?
        error "required #{terms} #{missing_keys.to_a} missing" + postscript
      end
      self
    end

    def require_n_of(n, *keys)
      permitted_keys.merge keys
      required_keys = keys.to_set
      if (missing_keys = required_keys - hash_keys).length > n
        error "#{n} or more #{terms} in #{missing_keys.to_a} must be given" + postscript
      end
      self
    end

    def require_one_of(*keys)
      require_n_of(1, *keys)
    end

    # Specifies keys that can exist with no further restrictions
    # Does no checking on its own
    def permit(*keys)
      permitted_keys.merge keys
      self
    end

    # Checks that only the the previously mentioned keys exist
    # In Rails, `permit' will do this as well, but having this as a separate
    # option allows for specifying permit not at the beginning of the chain
    def only
      unless (extra_keys = hash_keys - permitted_keys).empty?
        error "extra #{terms} #{extra_keys.to_a}" + postscript
      end
      self
    end

    # Similar to Rails' `permit' method.
    def permit_only(*keys)
      permit(*keys).only
    end

    def int(*keys)
      permitted_keys.merge keys
      keys.each do |key|
        next if hash[key].is_a? Integer
        error "#{term} #{key.inspect} must be integer but was #{hash[key].inspect}" + postscript
      end
      self
    end

    def int_or_nil(*keys)
      permitted_keys.merge keys
      keys.each do |key|
        next if hash[key].nil? || hash[key].is_a?(Integer)
        error "#{term} #{key.inspect} must be integer but was #{hash[key].inspect}" + postscript
      end
      self
    end

    def not_nil(*keys)
      permitted_keys.merge keys
      keys.each do |key|
        next unless hash[key].nil?
        error "#{term} #{key.inspect} is nil" + postscript
      end
      self
    end

    private

    def hash
      @string_keys ? @hash : @hash.symbolize_keys
    end

    def hash_keys
      (@string_keys ? @hash.keys : @hash.keys.map(&:to_sym)).to_set
    end

    attr_reader :permitted_keys, :term

    def error(message)
      raise @error_class, message
    end

    def postscript
      "\n\tin #{hash.inspect}"
    end

    def terms
      @terms ||= term.pluralize
    end
  end
end
