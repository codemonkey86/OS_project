##
# For handling WS-Policy related actions
# this will be able to understand basic WS-Policy schema
# to determine necessary requirements to have two services talk
# to each other
require 'nokogiri'
class Policy
  WS_XSD_PATH = RAILS_ROOT + '/lib/ws_policy/ws_policy.xsd'
  KINDS = %w(and one)

  attr_accessor :kind, :needs
  ##
  # creates a new policy object that describes polices
  # needed to support to talk to another service
  # input: ws_policy xml
  def initialize(xml)
   
    doc = Nokogiri::XML(xml)
    @needs = []
    doc.xpath('//wsp:Policy').children.each do |x|
      name = x.name
      if name == 'All'
        @kind = 'all'
      else
        @kind = 'one'
      end

      x.children.each do |pol|
        @needs << pol.name
      end
    end
  end

  ##
  # test to see if current supported policies also cover another
  # sevices required policies
  # input: currently supported policies and xml to test against
  def can_talk?(supported)
    diff = self.needs - supported
    if self.kind == 'all'
      diff.empty?
    else
      diff.size < self.needs.size
    end
  end

  ##
  # based on passed in xml, returns an array of supported policies
  def self.list_supported(xml)
    doc = Nokogiri::XML(xml)
    doc.xpath("//*[namespace-uri()='http://schemas.xmlsoap.org/ws/2005/07/securitypolicy']").collect{|x| x.name}
  end

  ##
  # wrapper method for testing purposes that opens a test file
  # returns the Nokogiri object
  def self.test_noko
    Nokogiri::XML(parse_file)
  end

  ##
  # similar to above but returns raw xml
  def self.parse_file(path = nil)
    f = File.open(path || "#{RAILS_ROOT}/lib/ws_policy/ws_test.xml", 'r+')
    xml = f.readlines.collect{|x| x.strip}.join
    f.close
    xml
  end
end
