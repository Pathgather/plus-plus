# PlusPlus (++)

Automatically increment/decrement integer columns with any value obeying any condition. Essentially, a more powerful form of Rails' counter_cache.

## Installation

Add this line to your application's Gemfile:
```ruby
gem 'plus_plus'
```

## Getting Started
The simplest use case for ++ is to simply increment/decrement a column keeping track of the count of an association (just like counter_cache):

```ruby
class Article < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
  include PlusPlus
  belongs_to :article

  plus_plus :article, :comments_count
end
```

```ruby
article = Article.create! content: "What an article!"
puts article.comments_count  # 0
comment = Comment.create! content: "You're right, that's one hell of an article!", article: article
puts article.comments_count  # 1
comment.destroy
puts article.comments_count  # 0
```

Simple enough! But what if we wanted to ignore a comment based on some condition?

```ruby
class Comment < ActiveRecord::Base
  include PlusPlus
  belongs_to :article

  plus_plus :article, :comments_count, unless: proc { fake_comment }  # Only increase if the comment is legit
end
```

Well, isn't that swell! But what if the owner of the comment toggles their comment to no longer be fake after it's already been created? Fine, geez!

```ruby
class Comment < ActiveRecord::Base
  include PlusPlus
  belongs_to :article

  plus_plus :article, :comments_count, unless: proc { fake_comment }  # Only increase if the comment is legit
  plus_plus_on_change :article, :comments_count, changed: :fake_comment, plus: false, minus: true
```

Ok ok, I see where you're going with this. But hey, I want to work in some gamification and up the user's score when they write articles and comments. Can I do that good sir?

```ruby
class User < ActiveRecord::Base
  has_many :articles
  has_many :comments
end

class Article < ActiveRecord::Base
  include PlusPlus
  belongs_to :user
  has_many :comments

  plus_plus :user, :score, value: proc { content.length }
  plus_plus :user, :articles_count, if: proc { published }
  plus_plus_on_change :user, :articles_count, changed: :published, plus: true, minus: false
end

class Comment < ActiveRecord::Base
  include PlusPlus
  belongs_to :user
  belongs_to :article

  plus_plus :user, :comments_count
  plus_plus :user, :score, value: 5, update_method: :update_attributes, unless: proc { fake_comment }
  plus_plus :article, :comments_count, unless: proc { fake_comment }
  plus_plus_on_change :article, :comments_count, changed: :fake_comment, plus: false, minus: true
  plus_plus_on_change :user, :score, changed: :fake_comment, plus: proc { !fake_comment }, minus: proc { fake_comment }, value: 5, update_method: :update_attributes
end
```

### Options
Let's bring it all home now:

**plus_plus**
- value: Defaults to 1. Can be set to a static integer value or a proc
- if: Only update if this condition is satisifed
- unless: Update unless this condition is satisifed
- update_method: Defaults to update_columns to avoid triggering callbacks and to be as fast as possible. Set to update_attributes or your own custom method if you prefer callbacks or something different.

**plus_plus_on_change**
- changed: (Required) The column to monitor for a change
- plus: (Required) The condition that must be satisfied in order to increment the column. Can be a proc (that evaluates to true/false) or a static value that will be checked for equality against the changed column
- minus: (Required) The condition that must be satisfied in order to decrement the column. Can be a proc (that evaluates to true/false) or a static value that will be checked for equality against the changed column
- value: Defaults to 1. Can be set to a static integer value or a proc
- update_method: Defaults to update_columns to avoid triggering callbacks and to be as fast as possible. Set to update_attributes or your own custom method if you prefer callbacks or something different.

The MIT License (MIT)
---------------------
Copyright (c) 2014 Pathgather

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
