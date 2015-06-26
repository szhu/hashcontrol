require 'hash_control/model'

describe HashControl::Model do
  before :all do
    class Comment
      include ::HashControl::Model
      require_key :author, :body, :date
      permit_key :image
    end

    class Something
      include ::HashControl::Model
      require_key :id
      permit_all_keys
    end
  end

  describe "making an instance should error if it" do
    it "does not permit all keys and has extra params" do
      expect {
        Comment.new(body: "this ain't gonna fly", author: 'me', date: Time.now, extra: 'hullo')
      }.to raise_error(ArgumentError)
      # ArgumentError: extra params [:extra]
      #   in {:body=>"this ain't gonna fly", :author=>"me", :date=>2014-01-01 00:00:00 -0000, :extra=>"hullo"}
    end

    it "is missing required params" do
      expect {
        Something.new(body: "this won't either")
      }.to raise_error(ArgumentError)
      # ArgumentError: required params [:id] missing
      #   in {:body=>"this won't either"}
    end
  end

  describe "a valid model" do
    describe "that permits only certain keys" do
      before :all do
        @comment = Comment.new(author: 'me', body: 'interesting stuff', date: Time.now)
      end

      describe "can use methods to access" do
        it "explicitly required and permitted keys" do
          expect(@comment.author).to eq('me')
          expect(@comment.body).to eq('interesting stuff')
          expect(@comment.date.class).to eq(Time)
          expect(@comment.image).to eq(nil)
        end
        it "not other keys" do
          expect { @comment.nonexistent }.to raise_error(NoMethodError)
        end
      end

      describe "can use [] (using both string and symbol) to access" do
        it "all keys regardless of whether they exist" do
          expect(@comment['author']).to eq('me')
          expect(@comment[:author]).to eq('me')
          expect(@comment['image']).to eq(nil)
          expect(@comment[:image]).to eq(nil)
          expect(@comment['nonexistent']).to eq(nil)
          expect(@comment[:nonexistent]).to eq(nil)
        end
      end

      it "#slice should work" do
        expect(@comment.slice(:author, :body).keys.to_set).to eq([:author, :body].to_set)
      end
    end

    describe "that permits all keys" do
      before :all do
        @something = Something.new(id: 1, body: "heh")
      end

      describe "can use methods to access" do
        it "explicitly required and permitted keys" do
          expect(@something.id).to eq(1)
        end
        it "not implicitly-permitted keys" do
          expect { @something.body }.to raise_error(NoMethodError)
          expect { @something.nonexistent }.to raise_error(NoMethodError)
        end
        it "not other keys" do
          expect { @something.body }.to raise_error(NoMethodError)
          expect { @something.nonexistent }.to raise_error(NoMethodError)
        end
      end

      describe "can use [] (using both string and symbol) to access" do
        it "all keys regardless of whether they exist" do
          expect(@something['body']).to eq('heh')
          expect(@something[:body]).to eq('heh')
          expect(@something['nonexistent']).to eq(nil)
          expect(@something[:nonexistent]).to eq(nil)
        end
      end

      it "#slice should work" do
        expect(@something.slice(:body).keys.to_set).to eq([:body].to_set)
      end
    end
  end
end
