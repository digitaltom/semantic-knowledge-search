require 'open-uri'

namespace :import do
  desc 'import documentation pages'
  task :doc, [:path] => [:environment] do |_, args|
    url = args[:path]
    import_from_url(url)
  end

  desc 'import knowledge base articles'
  task :kb, [:path] => [:environment] do |_, args|
    KB_IDS = (20_000..21_625).map{|id| id.to_s.rjust(9, '0')}
    urls = KB_IDS.map{|id| "https://www.suse.com/support/kb/doc/?id=#{id}"}.reverse
    urls = [args[:path]] if args[:path]
    urls.each{|url| import_from_url(url, selector: '#content', category: 'kb')}
  end

  desc 'import gh pages'
  task :gh, [:repo, :path] => [:environment] do |_, args|
    client = Octokit::Client.new(:access_token => ENV['GH_TOKEN'])
    file = client.contents(args.repo, path: args.path)
    name = "#{args.repo} - #{file.name}"
    content = Base64.decode64(file.content).force_encoding("UTF-8")
    update_article(name, content, file.html_url, 'github')
  end

  desc 'import articles by web crawling sites defined in sites.yml'
  task :crawl, [:site] => [:environment] do |_, args|
    sites_file = Rails.root.join('config', 'sites.yml')
    raise 'Please create a config/sites.yml file' unless File.exist?(sites_file)
    sites = YAML.load_file(Rails.root.join('config', 'sites.yml'))
    sites = { "#{args[:site]}": sites[args[:site]]} if args[:site]
    sites.keys.each do |site|
      sites[site]['links'] = sites[site]['links'].map{|l| Regexp.new(l)}
      puts "Starting Spidr with #{site} (links: #{sites[site]['links']}, selector: #{sites[site]['selector']})"
      # Spidr doesn't evaluate rejects when any accept filter is true
      Spidr.start_at(site.to_s, links: sites[site]['links']) do |agent|
        # Spidr agent (https://github.com/postmodern/spidr/blob/master/lib/spidr/agent.rb)
        agent.every_ok_page do |page|
          # iterating Spidr::Page (https://github.com/postmodern/spidr/blob/master/lib/spidr/page.rb)
          puts "On page #{page.url}"
          import_from_url(page.url.to_s, selector: sites[site]['selector'], category: sites[site]['category'])
        end
      end
    end
  end

  private

  def import_from_url(uri, selector: 'article, #content, .chapter, .article, .appendix, main',
                      category: 'doc')
    file = URI::open(uri)
    doc = Nokogiri::HTML(file)
    content = doc.css(selector).text.squeeze(" \n")
    title = doc.css('title').text
    title.gsub!(' | Support | SUSE', '')

    if !content || content == ""
      puts "No content found in uri, skipping..."
      return
    end

    update_article(title, content, uri, category)
  rescue OpenURI::HTTPError => e
    puts "No page at " + uri
  rescue Exception => e
    puts "Error: #{e.message}"
  end

  def update_article(title, content, uri, category)
    content_words = content.split
    # only index Llm::Api.create.class::MAX_EMBEDDINGS * 0.75 words
    content = content_words[0..(Llm::Api.create.class::MAX_EMBEDDINGS*0.75)].join(' ')
    Article.find_or_initialize_by(url: uri).tap do |a|
      a.update!(title: title, text: title + '\n' + content, category: category, indexed_at: DateTime.now)
      if a.previous_changes['embedding']
        puts "Stored '#{title}' from #{uri} (#{content.split.size}/#{content_words.size} words)"
      end
    end
  end

end
