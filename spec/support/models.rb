class User < ActiveRecord::Base
  has_many :articles
  has_many :comments
end

class Article < ActiveRecord::Base
  include PlusPlus
  belongs_to :user

  plus_plus :user, column: :articles_count, if: proc { published }
end

class Comment < ActiveRecord::Base
  include PlusPlus
  belongs_to :user

  plus_plus :user, column: :comments_count
end