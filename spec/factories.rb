require 'factory_girl'

FactoryGirl.define do
  factory :article do
    content 'Test Article'
    user
    published false

    factory :published_article do
      published true
    end

    factory :article_with_comment do
      after(:build) do |article, evaluator|
        article.comments << FactoryGirl.build_list(:comment, 1, article: nil)
      end
    end

    factory :article_with_subcomment do
      after(:build) do |article, evaluator|
        article.comments << FactoryGirl.build_list(:subcomment, 1, article: nil)
      end
    end
  end

  factory :comment do
    message 'Test Message'
    user
    article
    subcomment false

    factory :subcomment do
      subcomment true
    end
  end

  factory :user do
    name 'Test User'

    factory :user_with_published_article do
      after(:build) do |user, evaluator|
        user.articles << FactoryGirl.build_list(:published_article, 1, user: nil)
      end
    end

    factory :user_with_unpublished_article do
      after(:build) do |user, evaluator|
        user.articles << FactoryGirl.build_list(:article, 1, user: nil)
      end
    end

    factory :user_with_comment do
      after(:build) do |user, evaluator|
        user.comments << FactoryGirl.build_list(:comment, 1, user: nil)
      end
    end
  end
end
