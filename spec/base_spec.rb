require 'spec_helper'

describe PlusPlus do
  let(:article) { FactoryGirl.create(:article) }
  let(:article_with_comment) { FactoryGirl.create(:article_with_comment) }
  let(:article_with_subcomment) { FactoryGirl.create(:article_with_subcomment) }
  let(:user) { FactoryGirl.create(:user) }
  let(:user_with_comment) { FactoryGirl.create(:user_with_comment) }
  let(:user_with_published_article) { FactoryGirl.create(:user_with_published_article) }
  let(:user_with_unpublished_article) { FactoryGirl.create(:user_with_unpublished_article) }

  context "with the minimal configuration" do
    it "increases the column by 1 on create" do
      expect { FactoryGirl.create :comment, user: user }.to change{user.comments_count}.from(0).to(1)
    end

    it "decreases the column by 1 on destroy" do
      expect { user_with_comment.comments[0].destroy }.to change{user_with_comment.comments_count}.from(1).to(0)
    end
  end

  context "with a specified value" do
    it "increases the column by that value on create" do
      expect { FactoryGirl.create :comment, user: user }.to change{user.score}.from(0).to(5)
    end

    it "decreases the column by that value on destroy" do
      expect { user_with_comment.comments[0].destroy }.to change{user_with_comment.score}.from(5).to(0)
    end
  end

  context "with a dynamic value" do
    it "increases the column by that value on create" do
      expect { FactoryGirl.create :article, user: user, content: 'Test' }.to change{user.score}.from(0).to(4)
    end

    it "decreases the column by that value on destroy" do
      expect {
        user_with_published_article.articles[0].destroy
      }.to change{user_with_published_article.score}.from(user_with_published_article.articles[0].content.length).to(0)
    end
  end

  context "with an if condition" do
    context "when statisfied" do
      it "increases the column by 1 on create" do
        expect { FactoryGirl.create :published_article, user: user }.to change{user.articles_count}.from(0).to(1)
      end

      it "decreases the column by 1 on destroy" do
        expect { user_with_published_article.articles[0].destroy }.to change{user_with_published_article.articles_count}.from(1).to(0)
      end
    end

    context "when not statisfied" do
      it "does not increase the column on create" do
        expect { FactoryGirl.create :article, user: user }.to_not change{user.articles_count}
      end

      it "does not decrease the column on destroy" do
        expect { user_with_unpublished_article.articles[0].destroy }.to_not change{user_with_unpublished_article.articles_count}
      end
    end
  end

  context "with an unless condition" do
    context "when statisfied" do
      it "does not increase the column on create" do
        expect { FactoryGirl.create :subcomment, article: article }.to_not change{article.comments_count}
      end

      it "does not decrease the column on destroy" do
        expect { article_with_subcomment.comments[0].destroy }.to_not change{article_with_subcomment.comments_count}
      end
    end

    context "when not statisfied" do
      it "increases the column by 1 on create" do
        expect { FactoryGirl.create :comment, article: article }.to change{article.comments_count}.from(0).to(1)
      end

      it "decreases the column by 1 on destroy" do
        expect { article_with_comment.comments[0].destroy }.to change{article_with_comment.comments_count}.from(1).to(0)
      end
    end
  end

  it "should allow the user to specify if they want update_columns or update_attributes when a column is updated"
  it "should raise an error if the association is unknown"
  it "should raise an error if a column is not specified"
end