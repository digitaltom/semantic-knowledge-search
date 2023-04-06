class KnowledgeController < ApplicationController

  def index
    @kb_count = Article.where("url like '%support/kb%'").count
    @doc_count = Article.where("url like '%documentation.suse.com%'").count
  end

  def ask
    @kb_count = Article.where("url like '%support/kb%'").count
    @doc_count = Article.where("url like '%documentation.suse.com%'").count

    @question = Question.new(params[:question])
    @results = @question.related_articles
    if params[:article_id]
      @article = Article.find(params[:article_id])
    else
      raise "No articles found" if @results.blank?
      @article = Article.find(@results.first[:article_id])
    end
    @answer = Answer.new(@question, @article).generate
  end

end
