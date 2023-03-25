class KnowledgeController < ApplicationController

  def index
  end

  def ask
    @question = Question.new(params[:question])
    @results = @question.related_articles
    if params[:article_id]
      @article = Article.find(params[:article_id])
    else
      @article = Article.find(@results.first[:article_id])
    end
    @answer = Answer.new(@question, @article).generate
  end

end
