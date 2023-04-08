require 'benchmark'

class KnowledgeController < ApplicationController

  def index
    @kb_count = Article.kb.count
    @doc_count = Article.doc.count
  end

  def ask
    @kb_count = Article.kb.count
    @doc_count = Article.doc.count

    @question = Question.new(params[:question])
    time = Benchmark.measure {
      @results = @question.related_articles
    }
    logger.debug("Finding related articles took #{time}")
    if params[:article_id]
      @article = Article.find(params[:article_id])
    else
      raise "No articles found" if @results.blank?
      @article = Article.find(@results.first[:article_id])
    end
    @answer = Answer.new(@question, @article).generate
  end

end
