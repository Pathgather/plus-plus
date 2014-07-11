ActiveRecord::Schema.define do
  self.verbose = false

  create_table :articles, :force => true do |t|
    t.integer :user_id
    t.text :content
    t.boolean :published, default: false
    t.timestamps
  end

  create_table :comments, :force => true do |t|
    t.integer :user_id
    t.text :message
    t.timestamps
  end

  create_table :users, :force => true do |t|
    t.string :key
    t.string :name
    t.integer :articles_count, default: 0
    t.integer :comments_count, default: 0
    t.timestamps
  end

end