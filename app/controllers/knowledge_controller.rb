require 'benchmark'

class KnowledgeController < ApplicationController

  def index
    @article_counts = {
      'SUSE knowledge base articles': Article.kb.count,
      'documentation pages': Article.doc.count,
      'Trello cards': Article.trello.count,
      'Github pages': Article.gh.count,
    }
    @demo_question_1 = ENV["Q1"] || "How to use Yast?"
    @demo_question_2 = ENV["Q2"] || "How can I see inactive systems in SCC?"
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
      @articles = [Article.find(params[:article_id])]
    else
      raise "No articles found" if @results.blank?
      @articles = Article.where(id: @results.map{|r| r['article_id']})
    end
    time = Benchmark.measure {
      @answer = Answer.new(question, @articles).generate
    }
    @md_parser = Redcarpet::Markdown.new(Redcarpet::Render::HTML, extensions = {})
    logger.info("Generating answer took #{time.total.round(2)}s")
    render partial: 'answer'
  end

end
