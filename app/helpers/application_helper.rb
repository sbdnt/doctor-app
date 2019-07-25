module ApplicationHelper
  require 'nokogiri'
  ## --------- Helpers for front end side ----------##
  def strip_html(str)
    document = Nokogiri::HTML.parse(str)
    document.css("br").each { |node| node.replace("\n") }
    document.text
  end
  ## --------- Helpers for front end side ----------##
end
