namespace :import do
  desc 'import documentation pages'
  task :doc, [:path] => [:environment] do |_, args|

    URLS = [
      "https://documentation.suse.com/container/kubevirt/html/SLE-kubevirt/article-kubevirt.html",
      # scc
      "https://documentation.suse.com/subscription/suseconnect/html/SLE-suseconnect-visibility/article-suseconnect-visibility.html",
      # rmt
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/rmt-overview.html",
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/cha-rmt-installation.html",
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/cha-rmt-migrate.html",
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/cha-rmt-mirroring.html",
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/cha-rmt-client.html",
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/cha-rmt-tools.html",
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/cha-rmt-backup.html",
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/cha-manage-certificates.html",
      # sles
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/cha-adm-shell.html",
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/cha-adm-sudo.html",
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/cha-yast-gui.html",
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/cha-yast-text.html",
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/cha-yast-lang.html",
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/cha-yast-userman.html",
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/cha-onlineupdate-you.html",
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/cha-yast-software.html",
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/cha-sw-cl.html",
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/cha-snapper.html",
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/cha-klp.html",
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/cha-ulp.html",
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/cha-transactional-updates.html",
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/cha-vnc.html",
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/cha-net-rsync.html",
      # other sles docs
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/article-modules.html",
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/article-installation.html",
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/cha-upgrade-background.html",
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/cha-update-preparation.html",
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/cha-upgrade-offline.html",
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/cha-upgrade-online.html",
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/cha-upgrade-finish.html",
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/cha-upgrade-paths.html",
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/cha-upgrade-background.html",
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/cha-update-preparation.html",
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/cha-upgrade-offline.html",
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/cha-upgrade-online.html",
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/cha-upgrade-finish.html",
      "https://documentation.suse.com/sles/15-SP4/html/SLES-all/cha-update-backport.html",
      # Container Guide
      "https://documentation.suse.com/container/all/html/SLES-container/cha-containers-basics.html",
      "https://documentation.suse.com/container/all/html/SLES-container/cha-bci.html",
      "https://documentation.suse.com/container/all/html/SLES-container/cha-containers-build.html",
      "https://documentation.suse.com/container/all/html/SLES-container/cha-docker-installation.html",
      "https://documentation.suse.com/container/all/html/SLES-container/cha-registry-installation.html",
      "https://documentation.suse.com/container/all/html/SLES-container/cha-containers-get.html",
      "https://documentation.suse.com/container/all/html/SLES-container/cha-docker-building-images.html",
      "https://documentation.suse.com/container/all/html/SLES-container/cha-orchestration.html",
      "https://documentation.suse.com/container/all/html/SLES-container/cha-docker-containerize-app.html",
      "https://documentation.suse.com/container/all/html/SLES-container/cha-podman-overview.html",
      "https://documentation.suse.com/container/all/html/SLES-container/cha-buildah-overview.html",
      "https://documentation.suse.com/container/all/html/SLES-container/cha-containers-support.html",
      "https://documentation.suse.com/container/all/html/SLES-container/cha-containers-troubleshoot.html",
      "https://documentation.suse.com/container/all/html/SLES-container/cha-containers-terminology.html",
      # Public Cloud Guide
      "https://documentation.suse.com/sle-public-cloud/all/html/public-cloud/cha-intro.html",
      "https://documentation.suse.com/sle-public-cloud/all/html/public-cloud/cha-images.html",
      "https://documentation.suse.com/sle-public-cloud/all/html/public-cloud/cha-admin.html",
      "https://documentation.suse.com/sle-public-cloud/all/html/public-cloud/app-public-cloud-support.html"
    ]
    urls = URLS
    urls = [args[:path]] if args[:path]
    import_from_urls(urls)
  end

  desc 'import knowledge base articles'
  task :kb, [:path] => [:environment] do |_, args|
    KB_IDS = (20_000..21_034).map{|id| id.to_s.rjust(9, '0')}
    urls = KB_IDS.map{|id| "https://www.suse.com/support/kb/doc/?id=#{id}"}
    urls = [args[:path]] if args[:path]
    import_from_urls(urls)
  end


  private

  def import_from_urls(urls)
    urls.each do |uri|
      begin
        file = URI::open(uri)
        doc = Nokogiri::HTML(file)
        content = doc.css('#content').text.squeeze(" \n") if doc.at_css('#content')
        content = doc.css('.chapter').text.squeeze(" \n") if doc.at_css('.chapter')
        content = doc.css('.article').text.squeeze(" \n") if doc.at_css('.article')
        content = doc.css('.appendix').text.squeeze(" \n") if doc.at_css('.appendix')

        title = doc.css('#content h1').text
        title = doc.css('title').text if title = ""

        if !content || content == ""
          puts "No content found in uri, skipping..."
          next
        end
        content = content.split[0..1200].join(' ')
        Article.find_or_initialize_by(url: uri).tap do |a|
          a.update!(title: title, text: content, indexed_at: DateTime.now)
        end
        puts "Stored '#{title}' from " + uri
      rescue OpenURI::HTTPError => e
        puts "No page at " + uri
      end
    end
    Article.where(url: urls).each(&:vectorize)
  end

end
