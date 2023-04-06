#!/usr/bin/env ruby

require 'byebug'
require 'open-uri'
require 'rubygems'
require 'nokogiri'
require 'cgi'

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

URLS.each do |uri|

  begin
    file = URI::open(uri)
    doc = Nokogiri::HTML(file)
    content = doc.css('.chapter').text.squeeze(" \n") if doc.at_css('.chapter')
    content = doc.css('.article').text.squeeze(" \n") if doc.at_css('.article')
    content = doc.css('.appendix').text.squeeze(" \n") if doc.at_css('.appendix')
    title = doc.css('title').text

    if !content || content == ""
      puts "No content found in uri, skipping..."
      next
    end
    File.open(File.dirname(__FILE__) + "/../storage/training/docs/#{CGI.escape(title)}.txt", 'w') do |file|
      file.write(uri + "\n")
      file.write(title + "\n")
      file.write(content)
      puts "stored doc '#{title}' from " + uri
    end

  rescue OpenURI::HTTPError => e
    puts "no doc at " + uri
  end
end


