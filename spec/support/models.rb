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
end

class Comment < ActiveRecord::Base
  include PlusPlus
  belongs_to :user
  belongs_to :article

  plus_plus :user, :comments_count
  plus_plus :user, :score, value: 5, update_method: :update_attributes, unless: proc { subcomment }
  plus_plus :article, :comments_count, unless: proc { subcomment }
  plus_plus_on_change :article, :comments_count, changed: :subcomment, plus: false, minus: true
  plus_plus_on_change :user, :score, changed: :subcomment, plus: proc { !subcomment }, minus: proc { subcomment }, value: 5, update_method: :update_attributes
end