# HashControl

[![Build Status](https://travis-ci.org/szhu/hashcontrol.svg?branch=master)](https://travis-ci.org/szhu/hashcontrol)
[![Code Climate](https://codeclimate.com/github/szhu/hashcontrol/badges/gpa.svg)](https://codeclimate.com/github/szhu/hashcontrol)

```shell
gem install hash_control
```

This Ruby library provides some conveniences for using and manipulating hash-like data.

## Features

`HashControl::Model` is a class with

 - validation checking
 - getting and setting properties with both `[]` and accessor methods
 - setter methods can be omitted to prevent mutation
 - [AwesomePrint](https://github.com/michaeldv/awesome_print) support

Want just a single-use validator? Use `HashControl::Validator`.
 
## Examples

### Model

 ```ruby
require 'hash_control'
class Comment
  include ::HashControl::Model
  require_key :author, :body, :date
  permit_key :image
end

require 'hash_control'
class Something
  include ::HashControl::Model
  require_key :id
  permit_all_keys
end

Comment.new(author: 'me', body: 'interesting stuff', date: Time.now)

Comment.new(body: "this ain't gonna fly")
# ArgumentError: extra params [:extra]
#   in {:body=>"this ain't gonna fly", :author=>"me", :date=>2014-01-01 00:00:00 -0000, :extra=>"hullo"}

Something.new(body: "this, however, will")
# ArgumentError: required params [:id] missing
#   in {:body=>"this, however, will"}

Something.new(id: 1, body: "oops my bad")
```

### Validator

```ruby
require 'hash_control'
get_request = {
  get: '/api/article/23/comment/34/show'
}
post_request = {
  post: '/api/article/23/comment/34/update',
  body: {
    date: Time.new,
    body: 'hullo',
    meta: 'fsdkfsifhdsfsdhkj'
  }
}
validator = ::HashControl::Validator.new(post_request)
validator.require(:post).permit(:body).only
# `permit` marks keys as allowed but doesn't do any verification
# `only` ensures no other keys are present

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

CustomValidator.new(get_request).validate_get_request
CustomValidator.new(post_request).validate_post_request
```
