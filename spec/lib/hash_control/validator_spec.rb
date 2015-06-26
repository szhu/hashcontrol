require 'hash_control/validator'

describe HashControl::Validator do
  def validate(hash)
    ::HashControl::Validator.new(hash)
  end

  before :all do
    @empty = {
    }
    @get_request = {
      get: '/api/article/23/comment/34/show'
    }
    @post_request = {
      post: '/api/article/23/comment/34/update',
      body: {
        date: Time.new,
        body: 'hullo',
        meta: 'fsdkfsifhdsfsdhkj'
      }
    }
    @not_allowed_but_currently_ok = {
      get: 'something',
      post: 'something_else'
    }
  end

  describe "when used as its own class," do
    # `require` ensures certain keys are present
    it "require should work properly" do
      expect { validate(@post_request).require(:post) }.not_to raise_error
      expect { validate(@post_request).require(:body) }.not_to raise_error
      expect { validate(@post_request).require(:post, :body) }.not_to raise_error
      expect { validate(@post_request).require(:nonexistent) }.to raise_error(ArgumentError)
    end

    # `require_n_of` ensures at least n of certain keys are present
    it "require_n_of should work properly" do
      expect { validate(@post_request).require_n_of(2, :post, :body) }.not_to raise_error
    end

    # `permit` marks keys as allowed but doesn't do any verification
    it "permit should work properly" do
      expect { validate(@post_request).permit(:body) }.not_to raise_error
      expect { validate(@post_request).permit(:nonexistent) }.not_to raise_error
    end

    # `only` ensures no other keys are present
    it "only should work properly" do
      expect { validate(@post_request).only }.to raise_error(ArgumentError)
      expect { validate(@post_request).require(:post).only }.to raise_error(ArgumentError)
      expect { validate(@post_request).require(:post).permit(:body).only }.not_to raise_error
    end
  end

  describe "when subclassed," do
    before :all do
      class CustomValidator < ::HashControl::Validator
        def validate_request
          require_one_of(:get, :post)
        end

        def validate_get_request
          validate_request.only
        end

        def validate_post_request
          validate_request.permit(:body).only
        end
      end
    end

    it "should work properly for allowed hashes" do
      expect { CustomValidator.new(@get_request).validate_get_request }.not_to raise_error
      expect { CustomValidator.new(@post_request).validate_post_request }.not_to raise_error
      expect { CustomValidator.new(@not_allowed_but_currently_ok).validate_post_request }.not_to raise_error
    end

    it "should work properly for invalid hashes" do
      expect { CustomValidator.new(@empty).validate_get_request }.to raise_error(ArgumentError)
    end
  end
end
