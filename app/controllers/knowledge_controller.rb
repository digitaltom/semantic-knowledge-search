require 'benchmark'

class KnowledgeController < ApplicationController

  def index
    @kb_count = Article.kb.count
    @doc_count = Article.doc.count
  end

  def articles
    @question = Question.new(params[:q])
    time = Benchmark.measure {
      @results = @question.related_articles2
    }
    logger.info("Finding related articles took #{time.total.round(2)}s")
  end

  def answer

  end

  def ask

    @question = Question.new(params[:q])
    time = Benchmark.measure {
      @results = @question.related_articles2
    }
    logger.info("Finding related articles took #{time.total.round(2)}s")
    if params[:article_id]
      @article = Article.find(params[:article_id])
    else
      raise "No articles found" if @results.blank?
      @article = Article.find(@results.first['article_id'])
    end
    time = Benchmark.measure {
      @answer = Answer.new(@question, @article).generate
    }
    logger.info("Generating answer took #{time.total.round(2)}s")
  end

end
