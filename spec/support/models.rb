class User < ActiveRecord::Base
  has_many :articles
  has_many :comments
end

class Article < ActiveRecord::Base
  include PlusPlus
  belongs_to :user
  has_many :comments

  plus_plus :user, column: :articles_count, if: proc { published }
end

class Comment < ActiveRecord::Base
  include PlusPlus
  belongs_to :user
  belongs_to :article

  plus_plus :user, column: :comments_count
  plus_plus :article, column: :comments_count, unless: proc { subcomment }
end