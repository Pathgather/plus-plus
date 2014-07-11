class User < ActiveRecord::Base
end

class Comment < ActiveRecord::Base
  include PlusPlus
  belongs_to :user

  plus_plus :user, column: :comments_count
end