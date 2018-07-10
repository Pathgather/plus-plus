require 'spec_helper'

describe PlusPlus do
  let(:article) { FactoryGirl.create(:article) }
  let(:article_with_comment) { FactoryGirl.create(:article_with_comment) }
  let(:article_with_subcomment) { FactoryGirl.create(:article_with_subcomment) }
  let(:user) { FactoryGirl.create(:user) }
  let(:user_with_comment) { FactoryGirl.create(:user_with_comment) }
  let(:user_with_published_article) { FactoryGirl.create(:user_with_published_article) }
  let(:user_with_unpublished_article) { FactoryGirl.create(:user_with_unpublished_article) }

  describe 'plus_plus' do
    context 'with the minimal configuration' do
      it 'increases the column by 1 on create' do
        expect { FactoryGirl.create :comment, user: user }
          .to change { user.reload.comments_count }.from(0).to(1)
      end

      it 'decreases the column by 1 on destroy' do
        expect { user_with_comment.comments[0].destroy }
          .to change { user_with_comment.reload.comments_count }.from(1).to(0)
      end
    end

    context 'with a specified value' do
      it 'increases the column by that value on create' do
        expect { FactoryGirl.create :comment, user: user }
          .to change { user.reload.score }.from(0).to(5)
      end

      it 'decreases the column by that value on destroy' do
        expect { user_with_comment.comments[0].destroy }
          .to change { user_with_comment.reload.score }.from(5).to(0)
      end
    end

    context 'with a dynamic value' do
      it 'increases the column by that value on create' do
        expect { FactoryGirl.create :article, user: user, content: 'Test' }
          .to change { user.reload.score }.from(0).to(4)
      end

      it 'decreases the column by that value on destroy' do
        article = user_with_published_article.articles[0]
        expect { article.destroy }
          .to change { user_with_published_article.reload.score }
          .from(article.content.length).to(0)
      end
    end

    context 'with an if condition' do
      context 'when statisfied' do
        it 'increases the column by 1 on create' do
          expect { FactoryGirl.create :published_article, user: user }
            .to change { user.reload.articles_count }.from(0).to(1)
        end

        it 'decreases the column by 1 on destroy' do
          article = user_with_published_article.articles[0]
          expect { article.destroy }
            .to change { user_with_published_article.reload.articles_count }
            .from(1).to(0)
        end
      end

      context 'when not statisfied' do
        it 'does not increase the column on create' do
          expect { FactoryGirl.create :article, user: user }.to_not change { user.articles_count }
        end

        it 'does not decrease the column on destroy' do
          expect { user_with_unpublished_article.articles[0].destroy }.to_not change { user_with_unpublished_article.articles_count }
        end
      end
    end

    context 'with an unless condition' do
      context 'when statisfied' do
        it 'does not increase the column on create' do
          expect { FactoryGirl.create :subcomment, article: article }.to_not change { article.comments_count }
        end

        it 'does not decrease the column on destroy' do
          expect { article_with_subcomment.comments[0].destroy }.to_not change { article_with_subcomment.comments_count }
        end
      end

      context 'when not statisfied' do
        it 'increases the column by 1 on create' do
          expect { FactoryGirl.create :comment, article: article }
            .to change { article.reload.comments_count }.from(0).to(1)
        end

        it 'decreases the column by 1 on destroy' do
          comment = article_with_comment.comments[0]
          expect { comment.destroy }
            .to change { article_with_comment.reload.comments_count }.from(1).to(0)
        end
      end
    end
  end

  describe 'plus_plus_on_change' do
    context 'with the minimal configuration' do
      context 'when the :changed column is changed' do
        it 'updates the association with update_columns by default on create' do
          subcomment = FactoryGirl.create :subcomment, article: article
          subcomment.update_attributes subcomment: false
          expect(article.reload.comments_count).to eq(1)
        end

        context 'when plus is a set value' do
          it 'increases the column by 1 if :plus is satisfied' do
            subcomment = FactoryGirl.create :subcomment, article: article
            article.reload
            article.comments_count.should == 0
            subcomment.update_attributes subcomment: false
            article.reload
            article.comments_count.should == 1
          end
        end

        context 'when plus is a proc' do
          it 'increases the column by the proc value if :plus is satisfied' do
            subcomment = FactoryGirl.create :subcomment, user: user
            user.reload
            user.score.should == 0
            subcomment.update_attributes subcomment: false
            user.reload
            user.score.should == 5
          end
        end

        context 'when minus is a set valus' do
          it 'decreases the column by 1 if :minus is satisfied' do
            article_with_comment.reload
            article_with_comment.comments_count.should == 1
            article_with_comment.comments[0].update_attributes subcomment: true
            article_with_comment.reload
            article_with_comment.comments_count.should == 0
          end
        end

        context 'when minus is a proc' do
          it 'decreases the column by 1 if :minus is satisfied' do
            user_with_comment.reload
            user_with_comment.score.should == 5
            user_with_comment.comments[0].update_attributes subcomment: true
            user_with_comment.reload
            user_with_comment.score.should == 0
          end
        end
      end
    end
  end

  it 'should raise an error if the association is unknown'
  it 'should raise an error if a column is not specified'
end
