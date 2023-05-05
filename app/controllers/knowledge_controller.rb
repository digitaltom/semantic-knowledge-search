require 'benchmark'

class KnowledgeController < ApplicationController

  def index
    @kb_count = Article.kb.count
    @doc_count = Article.doc.count
    @question = params[:q]
  end

  def articles
    question = Question.new(params[:q][0..128])
    time = Benchmark.measure {
      @results = question.related_articles
    }
    logger.info("Finding related articles took #{time.total.round(2)}s")
    render partial: 'articles'
  end

  def answer
    question = Question.new(params[:q][0..128])
    time = Benchmark.measure {
      @results = question.related_articles
    }
    logger.info("Finding related articles took #{time.total.round(2)}s")
    if params[:article_id]
      @article = Article.find(params[:article_id])
    else
      raise "No articles found" if @results.blank?
      @article = Article.find(@results.first['article_id'])
    end
    time = Benchmark.measure {
      @answer = Answer.new(question, @article).generate
    }
    logger.info("Generating answer took #{time.total.round(2)}s")
    render partial: 'answer'
  end

end
