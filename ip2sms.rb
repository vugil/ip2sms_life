require 'nokogiri'
require 'open-uri'
require 'net/http'
class Ip2sms
  attr_accessor :login, :password, :source, :phone, :text

  def initialize login, password, source, phone, text
    @login = login
    @password = password
    @source = source
    @body = xml phone, text
  end

  def uri
    URI.parse "http://sms.businesslife.com.ua/clients.php"
  end

  def request
    request = Net::HTTP::Post.new uri.path
    request.body = @body
    request.basic_auth @login, @password
    request
  end

  def send
    begin
      Net::HTTP.new(uri.host, uri.port).request(request).body
    rescue Net::HTTPForbidden
      "403 Forbidden"
    end
  end

  def xml phone, text
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.message do
        xml.service source: @source, id: 'single'
        xml.to phone
        xml.body("content-type" => 'text/plain'){ xml.text text }
      end
    end.doc.root.to_xml
  end
end