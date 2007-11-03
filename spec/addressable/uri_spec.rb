#--
# Addressable, Copyright (c) 2006-2007 Bob Aman
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../../lib'))
$:.uniq!

require 'addressable/uri'

class ExampleProcessor
  def self.validate(name, value)
    return !!(value =~ /^[\w ]+$/) if name == "query"
    return true
  end
  
  def self.transform(name, value)
    return value.gsub(/ /, "+") if name == "query"
    return value
  end
  
  def self.restore(name, value)
    return value.gsub(/\+/, " ") if name == "query"
    return value
  end
 
  def self.match(name)
    return ".*?" if name == "first"
    return ".*"
  end
end

describe Addressable::URI, "when created from nil components" do
  it "should raise an error" do
    (lambda do
      Addressable::URI.new(nil, nil, nil, nil, nil, nil, nil, nil)
    end).should raise_error(Addressable::URI::InvalidURIError)
  end
end

describe Addressable::URI, "when created with a non-numeric port number" do
  it "should raise an error" do
    (lambda do
      Addressable::URI.new(nil, nil, nil, nil, "bogus", nil, nil, nil)
    end).should raise_error(Addressable::URI::InvalidURIError)
  end
end

describe Addressable::URI, "when created with a scheme but no hierarchical " +
    "segment" do
  it "should raise an error" do
    (lambda do
      Addressable::URI.parse("http:")
    end).should raise_error(Addressable::URI::InvalidURIError)
  end
end

describe Addressable::URI, "when created from string components" do
  before do
    @uri = Addressable::URI.new(
      "http", nil, nil, "example.com", nil, nil, nil, nil)
  end

  it "should be equal to the equivalent parsed URI" do
    @uri.should == Addressable::URI.parse("http://example.com")
  end
end

# Section 1.1.2 of RFC 3986
describe Addressable::URI, " when parsed from " +
    "'ftp://ftp.is.co.za/rfc/rfc1808.txt'" do
  before do
    @uri = Addressable::URI.parse("ftp://ftp.is.co.za/rfc/rfc1808.txt")
  end

  it "should use the 'ftp' scheme" do
    @uri.scheme.should == "ftp"
  end

  it "should be considered to be ip-based" do
    @uri.should be_ip_based
  end

  it "should have a host of 'ftp.is.co.za'" do
    @uri.host.should == "ftp.is.co.za"
  end

  it "should have a path of '/rfc/rfc1808.txt'" do
    @uri.path.should == "/rfc/rfc1808.txt"
  end

  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end
end

# Section 1.1.2 of RFC 3986
describe Addressable::URI, " when parsed from " +
    "'http://www.ietf.org/rfc/rfc2396.txt'" do
  before do
    @uri = Addressable::URI.parse("http://www.ietf.org/rfc/rfc2396.txt")
  end

  it "should use the 'http' scheme" do
    @uri.scheme.should == "http"
  end

  it "should be considered to be ip-based" do
    @uri.should be_ip_based
  end

  it "should have a host of 'www.ietf.org'" do
    @uri.host.should == "www.ietf.org"
  end

  it "should have a path of '/rfc/rfc2396.txt'" do
    @uri.path.should == "/rfc/rfc2396.txt"
  end

  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end
end

# Section 1.1.2 of RFC 3986
describe Addressable::URI, "when parsed from " +
    "'ldap://[2001:db8::7]/c=GB?objectClass?one'" do
  before do
    @uri = Addressable::URI.parse("ldap://[2001:db8::7]/c=GB?objectClass?one")
  end

  it "should use the 'ldap' scheme" do
    @uri.scheme.should == "ldap"
  end

  it "should be considered to be ip-based" do
    @uri.should be_ip_based
  end

  it "should have a host of '[2001:db8::7]'" do
    @uri.host.should == "[2001:db8::7]"
  end

  it "should have a path of '/c=GB'" do
    @uri.path.should == "/c=GB"
  end

  it "should have a query of 'objectClass?one'" do
    @uri.query.should == "objectClass?one"
  end

  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end
end

# Section 1.1.2 of RFC 3986
describe Addressable::URI, " when parsed from " +
    "'mailto:John.Doe@example.com'" do
  before do
    @uri = Addressable::URI.parse("mailto:John.Doe@example.com")
  end

  it "should use the 'mailto' scheme" do
    @uri.scheme.should == "mailto"
  end

  it "should not be considered to be ip-based" do
    @uri.should_not be_ip_based
  end

  it "should have a path of 'John.Doe@example.com'" do
    @uri.path.should == "John.Doe@example.com"
  end

  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end
end

# Section 1.1.2 of RFC 3986
describe Addressable::URI, " when parsed from " +
    "'news:comp.infosystems.www.servers.unix'" do
  before do
    @uri = Addressable::URI.parse("news:comp.infosystems.www.servers.unix")
  end

  it "should use the 'news' scheme" do
    @uri.scheme.should == "news"
  end

  it "should not be considered to be ip-based" do
    @uri.should_not be_ip_based
  end

  it "should have a path of 'comp.infosystems.www.servers.unix'" do
    @uri.path.should == "comp.infosystems.www.servers.unix"
  end

  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end
end

# Section 1.1.2 of RFC 3986
describe Addressable::URI, "when parsed from " +
    "'tel:+1-816-555-1212'" do
  before do
    @uri = Addressable::URI.parse("tel:+1-816-555-1212")
  end

  it "should use the 'tel' scheme" do
    @uri.scheme.should == "tel"
  end

  it "should not be considered to be ip-based" do
    @uri.should_not be_ip_based
  end

  it "should have a path of '+1-816-555-1212'" do
    @uri.path.should == "+1-816-555-1212"
  end

  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end
end

# Section 1.1.2 of RFC 3986
describe Addressable::URI, " when parsed from " +
    "'telnet://192.0.2.16:80/'" do
  before do
    @uri = Addressable::URI.parse("telnet://192.0.2.16:80/")
  end

  it "should use the 'telnet' scheme" do
    @uri.scheme.should == "telnet"
  end

  it "should have a host of '192.0.2.16'" do
    @uri.host.should == "192.0.2.16"
  end

  it "should have a port of '80'" do
    @uri.port.should == 80
  end

  it "should be considered to be ip-based" do
    @uri.should be_ip_based
  end

  it "should have a path of '/'" do
    @uri.path.should == "/"
  end

  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end
end

# Section 1.1.2 of RFC 3986
describe Addressable::URI, " when parsed from " +
    "'urn:oasis:names:specification:docbook:dtd:xml:4.1.2'" do
  before do
    @uri = Addressable::URI.parse(
      "urn:oasis:names:specification:docbook:dtd:xml:4.1.2")
  end

  it "should use the 'urn' scheme" do
    @uri.scheme.should == "urn"
  end

  it "should not be considered to be ip-based" do
    @uri.should_not be_ip_based
  end

  it "should have a path of " +
      "'oasis:names:specification:docbook:dtd:xml:4.1.2'" do
    @uri.path.should == "oasis:names:specification:docbook:dtd:xml:4.1.2"
  end

  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end
end

describe Addressable::URI, " when parsed from " +
    "'http://example.com'" do
  before do
    @uri = Addressable::URI.parse("http://example.com")
  end

  it "when inspected, should have the correct URI" do
    @uri.inspect.should include("http://example.com")
  end

  it "should use the 'http' scheme" do
    @uri.scheme.should == "http"
  end

  it "should be considered to be ip-based" do
    @uri.should be_ip_based
  end

  it "should have an authority segment of 'example.com'" do
    @uri.authority.should == "example.com"
  end

  it "should have a host of 'example.com'" do
    @uri.host.should == "example.com"
  end

  it "should be considered ip-based" do
    @uri.should be_ip_based
  end

  it "should have no username" do
    @uri.user.should == nil
  end

  it "should have no password" do
    @uri.password.should == nil
  end
  
  it "should use port 80" do
    @uri.port.should == 80
  end
  
  it "should not have a specified port" do
    @uri.specified_port.should == nil
  end

  it "should have an empty path" do
    @uri.path.should == ""
  end

  it "should have no query string" do
    @uri.query.should == nil
  end

  it "should have no fragment" do
    @uri.fragment.should == nil
  end

  it "should be considered absolute" do
    @uri.should be_absolute
  end

  it "should not be considered relative" do
    @uri.should_not be_relative
  end

  it "should not be exactly equal to 42" do
    @uri.eql?(42).should == false
  end

  it "should not be equal to 42" do
    (@uri == 42).should == false
  end
  
  it "should not be roughly equal to 42" do
    (@uri === 42).should == false
  end

  it "should be exactly equal to http://example.com" do
    @uri.eql?(Addressable::URI.parse("http://example.com")).should == true
  end

  it "should be roughly equal to http://example.com/" do
    (@uri === Addressable::URI.parse("http://example.com/")).should == true
  end

  it "should be roughly equal to the string 'http://example.com/'" do
    (@uri === "http://example.com/").should == true
  end

  it "should not be roughly equal to the string " +
      "'http://example.com:bogus/'" do
    (lambda do
      (@uri === "http://example.com:bogus/").should == false
    end).should_not raise_error
  end

  it "should result in itself when merged with itself" do
    @uri.merge(@uri).to_s.should == "http://example.com"
    @uri.merge!(@uri).to_s.should == "http://example.com"
  end

  # Section 6.2.3 of RFC 3986
  it "should be equivalent to http://example.com/" do
    @uri.should == Addressable::URI.parse("http://example.com/")
  end

  # Section 6.2.3 of RFC 3986
  it "should be equivalent to http://example.com:/" do
    @uri.should == Addressable::URI.parse("http://example.com:/")
  end

  # Section 6.2.3 of RFC 3986
  it "should be equivalent to http://example.com:80/" do
    @uri.should == Addressable::URI.parse("http://example.com:80/")
  end

  # Section 6.2.2.1 of RFC 3986
  it "should be equivalent to http://EXAMPLE.COM/" do
    @uri.should == Addressable::URI.parse("http://EXAMPLE.COM/")
  end
  
  it "should have a route of '/path/' to 'http://example.com/path/'" do
    @uri.route_to("http://example.com/path/").should ==
      Addressable::URI.parse("/path/")
  end
  
  it "should have a route of '/' from 'http://example.com/path/'" do
    @uri.route_from("http://example.com/path/").should ==
      Addressable::URI.parse("/")
  end
  
  it "should have a route of '#' to 'http://example.com/'" do
    @uri.route_to("http://example.com/").should ==
      Addressable::URI.parse("#")
  end
  
  it "should have a route of 'http://elsewhere.com/' to " +
      "'http://elsewhere.com/'" do
    @uri.route_to("http://elsewhere.com/").should ==
      Addressable::URI.parse("http://elsewhere.com/")
  end

  it "when joined with 'relative/path' should be " +
      "'http://example.com/relative/path'" do
    @uri.join('relative/path').should ==
      Addressable::URI.parse("http://example.com/relative/path")
  end

  it "should have the correct username after assignment" do
    @uri.user = "newuser"
    @uri.user.should == "newuser"
    @uri.password.should == nil
    @uri.to_s.should == "http://newuser@example.com"
  end

  it "should have the correct password after assignment" do
    @uri.password = "newpass"
    @uri.password.should == "newpass"
    @uri.user.should == ""
    @uri.to_s.should == "http://:newpass@example.com"
  end
  
  it "should have the correct user/pass after repeated assignment" do
    @uri.user = nil
    @uri.user.should == nil
    @uri.password = "newpass"
    @uri.password.should == "newpass"
    # Username cannot be nil if the password is set
    @uri.user.should == ""
    @uri.to_s.should == "http://:newpass@example.com"
    @uri.user = "newuser"
    @uri.user.should == "newuser"
    @uri.password = nil
    @uri.password.should == nil
    @uri.to_s.should == "http://newuser@example.com"
    @uri.user = "newuser"
    @uri.user.should == "newuser"
    @uri.password = ""
    @uri.password.should == ""
    @uri.to_s.should == "http://newuser:@example.com"
    @uri.password = "newpass"
    @uri.password.should == "newpass"
    @uri.user = nil
    # Username cannot be nil if the password is set
    @uri.user.should == ""
    @uri.to_s.should == "http://:newpass@example.com"
  end
  
  it "should have the correct user/pass after userinfo assignment" do
    @uri.user = "newuser"
    @uri.user.should == "newuser"
    @uri.password = "newpass"
    @uri.password.should == "newpass"
    @uri.userinfo = nil
    @uri.userinfo.should == nil
    @uri.user.should == nil
    @uri.password.should == nil
  end
  
  it "should correctly convert to a hash" do
    @uri.to_h.should == {
      :scheme => "http",
      :user => nil,
      :password => nil,
      :host => "example.com",
      :port => nil,
      :path => "",
      :query => nil,
      :fragment => nil
    }
  end
end

describe Addressable::URI, " when parsed from " +
    "'http://example.com/'" do
  before do
    @uri = Addressable::URI.parse("http://example.com/")
  end
  
  # Based on http://intertwingly.net/blog/2004/07/31/URI-Equivalence
  it "should be equivalent to http://example.com" do
    @uri.should == Addressable::URI.parse("http://example.com")
  end

  # Based on http://intertwingly.net/blog/2004/07/31/URI-Equivalence
  it "should be equivalent to HTTP://example.com/" do
    @uri.should == Addressable::URI.parse("HTTP://example.com/")
  end

  # Based on http://intertwingly.net/blog/2004/07/31/URI-Equivalence
  it "should be equivalent to http://example.com:/" do
    @uri.should == Addressable::URI.parse("http://example.com:/")
  end

  # Based on http://intertwingly.net/blog/2004/07/31/URI-Equivalence
  it "should be equivalent to http://example.com:80/" do
    @uri.should == Addressable::URI.parse("http://example.com:80/")
  end

  # Based on http://intertwingly.net/blog/2004/07/31/URI-Equivalence
  it "should be equivalent to http://Example.com/" do
    @uri.should == Addressable::URI.parse("http://Example.com/")
  end

  it "should have the correct username after assignment" do
    @uri.user = nil
    @uri.user.should == nil
    @uri.password.should == nil
    @uri.to_s.should == "http://example.com/"
  end

  it "should have the correct password after assignment" do
    @uri.password = nil
    @uri.password.should == nil
    @uri.user.should == nil
    @uri.to_s.should == "http://example.com/"
  end
  
  it "should correctly convert to a hash" do
    @uri.to_h.should == {
      :scheme => "http",
      :user => nil,
      :password => nil,
      :host => "example.com",
      :port => nil,
      :path => "/",
      :query => nil,
      :fragment => nil
    }
  end
end

describe Addressable::URI, " when parsed from " +
    "'http://@example.com/'" do
  before do
    @uri = Addressable::URI.parse("http://@example.com/")
  end
  
  it "should be equivalent to http://example.com" do
    @uri.should == Addressable::URI.parse("http://example.com")
  end
  
  it "should correctly convert to a hash" do
    @uri.to_h.should == {
      :scheme => "http",
      :user => "",
      :password => nil,
      :host => "example.com",
      :port => nil,
      :path => "/",
      :query => nil,
      :fragment => nil
    }
  end
end

describe Addressable::URI, " when parsed from " +
    "'http://example.com./'" do
  before do
    @uri = Addressable::URI.parse("http://example.com./")
  end
  
  it "should be equivalent to http://example.com" do
    @uri.should == Addressable::URI.parse("http://example.com")
  end

  it "should not be considered to be in normal form" do
    @uri.normalize.should_not be_eql(@uri)
  end
end

describe Addressable::URI, " when parsed from " +
    "'http://:@example.com/'" do
  before do
    @uri = Addressable::URI.parse("http://:@example.com/")
  end
  
  it "should be equivalent to http://example.com" do
    @uri.should == Addressable::URI.parse("http://example.com")
  end
  
  it "should correctly convert to a hash" do
    @uri.to_h.should == {
      :scheme => "http",
      :user => "",
      :password => "",
      :host => "example.com",
      :port => nil,
      :path => "/",
      :query => nil,
      :fragment => nil
    }
  end
end

describe Addressable::URI, " when parsed from " +
    "'http://example.com/~smith/'" do
  before do
    @uri = Addressable::URI.parse("http://example.com/~smith/")
  end

  # Based on http://intertwingly.net/blog/2004/07/31/URI-Equivalence
  it "should be equivalent to http://example.com/%7Esmith/" do
    @uri.should == Addressable::URI.parse("http://example.com/%7Esmith/")
  end

  # Based on http://intertwingly.net/blog/2004/07/31/URI-Equivalence
  it "should be equivalent to http://example.com/%7esmith/" do
    @uri.should == Addressable::URI.parse("http://example.com/%7esmith/")
  end
end

describe Addressable::URI, " when parsed from " +
    "'http://example.com/%C3%87'" do
  before do
    @uri = Addressable::URI.parse("http://example.com/%C3%87")
  end

  # Based on http://intertwingly.net/blog/2004/07/31/URI-Equivalence
  it "should be equivalent to 'http://example.com/C%CC%A7'" do
    @uri.should == Addressable::URI.parse("http://example.com/C%CC%A7")
  end
  
  it "should not change if encoded with the normalizing algorithm" do
    Addressable::URI.normalized_encode(@uri).to_s.should == 
      "http://example.com/%C3%87"
  end
  
  it "if percent encoded should be 'http://example.com/C%25CC%25A7'" do
    Addressable::URI.encode(@uri).to_s.should ==
      "http://example.com/%25C3%2587"
  end
end

describe Addressable::URI, " when parsed from " +
    "'http://example.com/?q=string'" do
  before do
    @uri = Addressable::URI.parse("http://example.com/?q=string")
  end

  it "should use the 'http' scheme" do
    @uri.scheme.should == "http"
  end

  it "should have an authority segment of 'example.com'" do
    @uri.authority.should == "example.com"
  end

  it "should have a host of 'example.com'" do
    @uri.host.should == "example.com"
  end

  it "should have no username" do
    @uri.user.should == nil
  end

  it "should have no password" do
    @uri.password.should == nil
  end
  
  it "should use port 80" do
    @uri.port.should == 80
  end

  it "should have a path of '/'" do
    @uri.path.should == "/"
  end

  it "should have a query string of 'q=string'" do
    @uri.query.should == "q=string"
  end

  it "should have no fragment" do
    @uri.fragment.should == nil
  end

  it "should be considered absolute" do
    @uri.should be_absolute
  end

  it "should not be considered relative" do
    @uri.should_not be_relative
  end
  
  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end
end

describe Addressable::URI, " when parsed from " +
    "'http://example.com:80/'" do
  before do
    @uri = Addressable::URI.parse("http://example.com:80/")
  end

  it "should use the 'http' scheme" do
    @uri.scheme.should == "http"
  end

  it "should have an authority segment of 'example.com:80'" do
    @uri.authority.should == "example.com:80"
  end

  it "should have a host of 'example.com'" do
    @uri.host.should == "example.com"
  end

  it "should have no username" do
    @uri.user.should == nil
  end

  it "should have no password" do
    @uri.password.should == nil
  end
  
  it "should use port 80" do
    @uri.port.should == 80
  end

  it "should have a path of '/'" do
    @uri.path.should == "/"
  end

  it "should have no query string" do
    @uri.query.should == nil
  end

  it "should have no fragment" do
    @uri.fragment.should == nil
  end

  it "should be considered absolute" do
    @uri.should be_absolute
  end

  it "should not be considered relative" do
    @uri.should_not be_relative
  end

  it "should be exactly equal to http://example.com:80/" do
    @uri.eql?(Addressable::URI.parse("http://example.com:80/")).should == true
  end

  it "should be roughly equal to http://example.com/" do
    (@uri === Addressable::URI.parse("http://example.com/")).should == true
  end

  it "should be roughly equal to the string 'http://example.com/'" do
    (@uri === "http://example.com/").should == true
  end

  it "should not be roughly equal to the string " +
      "'http://example.com:bogus/'" do
    (lambda do
      (@uri === "http://example.com:bogus/").should == false
    end).should_not raise_error
  end

  it "should result in itself when merged with itself" do
    @uri.merge(@uri).to_s.should == "http://example.com:80/"
    @uri.merge!(@uri).to_s.should == "http://example.com:80/"
  end

  # Section 6.2.3 of RFC 3986
  it "should be equal to http://example.com/" do
    @uri.should == Addressable::URI.parse("http://example.com/")
  end

  # Section 6.2.3 of RFC 3986
  it "should be equal to http://example.com:/" do
    @uri.should == Addressable::URI.parse("http://example.com:/")
  end

  # Section 6.2.3 of RFC 3986
  it "should be equal to http://example.com:80/" do
    @uri.should == Addressable::URI.parse("http://example.com:80/")
  end

  # Section 6.2.2.1 of RFC 3986
  it "should be equal to http://EXAMPLE.COM/" do
    @uri.should == Addressable::URI.parse("http://EXAMPLE.COM/")
  end
end

describe Addressable::URI, "when parsed from " +
    "'relative/path/to/resource'" do
  before do
    @uri = Addressable::URI.parse("relative/path/to/resource")
  end

  it "should not have a scheme" do
    @uri.scheme.should == nil
  end

  it "should not be considered ip-based" do
    @uri.should_not be_ip_based
  end

  it "should not have an authority segment" do
    @uri.authority.should == nil
  end

  it "should not have a host" do
    @uri.host.should == nil
  end

  it "should have no username" do
    @uri.user.should == nil
  end

  it "should have no password" do
    @uri.password.should == nil
  end
  
  it "should not have a port" do
    @uri.port.should == nil
  end

  it "should have a path of 'relative/path/to/resource'" do
    @uri.path.should == "relative/path/to/resource"
  end

  it "should have no query string" do
    @uri.query.should == nil
  end

  it "should have no fragment" do
    @uri.fragment.should == nil
  end

  it "should not be considered absolute" do
    @uri.should_not be_absolute
  end

  it "should be considered relative" do
    @uri.should be_relative
  end

  it "should raise an error if routing is attempted" do
    (lambda do
      @uri.route_to("http://example.com/")
    end).should raise_error
    (lambda do
      @uri.route_from("http://example.com/")
    end).should raise_error
  end
  
  it "when joined with 'another/relative/path' should be " +
      "'relative/path/to/another/relative/path'" do
    @uri.join('another/relative/path').should ==
      Addressable::URI.parse("relative/path/to/another/relative/path")    
  end
end

describe Addressable::URI, "when parsed from " +
    "'relative_path_with_no_slashes'" do
  before do
    @uri = Addressable::URI.parse("relative_path_with_no_slashes")
  end

  it "should not have a scheme" do
    @uri.scheme.should == nil
  end

  it "should not be considered ip-based" do
    @uri.should_not be_ip_based
  end

  it "should not have an authority segment" do
    @uri.authority.should == nil
  end

  it "should not have a host" do
    @uri.host.should == nil
  end

  it "should have no username" do
    @uri.user.should == nil
  end

  it "should have no password" do
    @uri.password.should == nil
  end
  
  it "should not have a port" do
    @uri.port.should == nil
  end

  it "should have a path of 'relative_path_with_no_slashes'" do
    @uri.path.should == "relative_path_with_no_slashes"
  end

  it "should have no query string" do
    @uri.query.should == nil
  end

  it "should have no fragment" do
    @uri.fragment.should == nil
  end

  it "should not be considered absolute" do
    @uri.should_not be_absolute
  end

  it "should be considered relative" do
    @uri.should be_relative
  end

  it "when joined with 'another_relative_path' should be " +
      "'another_relative_path'" do
    @uri.join('another_relative_path').should ==
      Addressable::URI.parse("another_relative_path")    
  end
end

describe Addressable::URI, " when parsed from " +
    "'http://example.com/file.txt'" do
  before do
    @uri = Addressable::URI.parse("http://example.com/file.txt")
  end

  it "should have a scheme of 'http'" do
    @uri.scheme.should == "http"
  end
  
  it "should have an authority segment of 'example.com'" do
    @uri.authority.should == "example.com"
  end

  it "should have a host of 'example.com'" do
    @uri.host.should == "example.com"
  end

  it "should have no username" do
    @uri.user.should == nil
  end

  it "should have no password" do
    @uri.password.should == nil
  end
  
  it "should use port 80" do
    @uri.port.should == 80
  end

  it "should have a path of '/file.txt'" do
    @uri.path.should == "/file.txt"
  end

  it "should have an extname of '.txt'" do
    @uri.extname.should == ".txt"
  end

  it "should have no query string" do
    @uri.query.should == nil
  end

  it "should have no fragment" do
    @uri.fragment.should == nil
  end
end

describe Addressable::URI, " when parsed from " +
    "'http://example.com/file.txt;x=y'" do
  before do
    @uri = Addressable::URI.parse("http://example.com/file.txt;x=y")
  end

  it "should have a scheme of 'http'" do
    @uri.scheme.should == "http"
  end

  it "should have a scheme of 'http'" do
    @uri.scheme.should == "http"
  end
  
  it "should have an authority segment of 'example.com'" do
    @uri.authority.should == "example.com"
  end

  it "should have a host of 'example.com'" do
    @uri.host.should == "example.com"
  end

  it "should have no username" do
    @uri.user.should == nil
  end

  it "should have no password" do
    @uri.password.should == nil
  end
  
  it "should use port 80" do
    @uri.port.should == 80
  end

  it "should have a path of '/file.txt;x=y'" do
    @uri.path.should == "/file.txt;x=y"
  end

  it "should have an extname of '.txt'" do
    @uri.extname.should == ".txt"
  end

  it "should have no query string" do
    @uri.query.should == nil
  end

  it "should have no fragment" do
    @uri.fragment.should == nil
  end
  
  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end
end

describe Addressable::URI, " when parsed from " +
    "'mailto:user@example.com'" do
  before do
    @uri = Addressable::URI.parse("mailto:user@example.com")
  end

  it "should have a scheme of 'mailto'" do
    @uri.scheme.should == "mailto"
  end

  it "should not be considered to be ip-based" do
    @uri.should_not be_ip_based
  end

  it "should have a path of 'user@example.com'" do
    @uri.path.should == "user@example.com"
  end

  it "should have no user" do
    @uri.user.should == nil
  end
  
  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end
end

describe Addressable::URI, " when parsed from " +
    "'tag:example.com,2006-08-18:/path/to/something'" do
  before do
    @uri = Addressable::URI.parse(
      "tag:example.com,2006-08-18:/path/to/something")
  end

  it "should have a scheme of 'tag'" do
    @uri.scheme.should == "tag"
  end

  it "should be considered to be ip-based" do
    @uri.should_not be_ip_based
  end

  it "should have a path of " +
      "'example.com,2006-08-18:/path/to/something'" do
    @uri.path.should == "example.com,2006-08-18:/path/to/something"
  end

  it "should have no user" do
    @uri.user.should == nil
  end
  
  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end
end

describe Addressable::URI, " when parsed from " +
    "'http://example.com/x;y/'" do
  before do
    @uri = Addressable::URI.parse("http://example.com/x;y/")
  end
  
  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end
end

describe Addressable::URI, " when parsed from " +
    "'http://example.com/?x=1&y=2'" do
  before do
    @uri = Addressable::URI.parse("http://example.com/?x=1&y=2")
  end
  
  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end
end

describe Addressable::URI, " when parsed from " +
    "'view-source:http://example.com/'" do
  before do
    @uri = Addressable::URI.parse("view-source:http://example.com/")
  end

  it "should have a scheme of 'view-source'" do
    @uri.scheme.should == "view-source"
  end

  it "should have a path of 'http://example.com/'" do
    @uri.path.should == "http://example.com/"
  end
  
  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end
end

describe Addressable::URI, " when parsed from " +
    "'http://user:pass@example.com/path/to/resource?query=x#fragment'" do
  before do
    @uri = Addressable::URI.parse(
      "http://user:pass@example.com/path/to/resource?query=x#fragment")
  end

  it "should use the 'http' scheme" do
    @uri.scheme.should == "http"
  end
  
  it "should have an authority segment of 'user:pass@example.com'" do
    @uri.authority.should == "user:pass@example.com"
  end

  it "should have a username of 'user'" do
    @uri.user.should == "user"
  end

  it "should have a password of 'pass'" do
    @uri.password.should == "pass"
  end
  
  it "should have a host of 'example.com'" do
    @uri.host.should == "example.com"
  end

  it "should use port 80" do
    @uri.port.should == 80
  end

  it "should have a path of '/path/to/resource'" do
    @uri.path.should == "/path/to/resource"
  end

  it "should have a query string of 'query=x'" do
    @uri.query.should == "query=x"
  end

  it "should have a fragment of 'fragment'" do
    @uri.fragment.should == "fragment"
  end
  
  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end

  it "should have a route of '/path/' to " +
      "'http://user:pass@example.com/path/'" do
    @uri.route_to("http://user:pass@example.com/path/").should ==
      Addressable::URI.parse("/path/")
  end
  
  it "should have a route of '/path/to/resource?query=x#fragment' " +
      "from 'http://user:pass@example.com/path/'" do
    @uri.route_from("http://user:pass@example.com/path/").should ==
      Addressable::URI.parse("/path/to/resource?query=x#fragment")
  end
  
  it "should have a route of '?query=x#fragment' " +
      "from 'http://user:pass@example.com/path/to/resource'" do
    @uri.route_from("http://user:pass@example.com/path/to/resource").should ==
      Addressable::URI.parse("?query=x#fragment")
  end
  
  it "should have a route of '#fragment' " +
      "from 'http://user:pass@example.com/path/to/resource?query=x'" do
    @uri.route_from(
      "http://user:pass@example.com/path/to/resource?query=x").should ==
        Addressable::URI.parse("#fragment")
  end
  
  it "should have a route of '#fragment' from " +
      "'http://user:pass@example.com/path/to/resource?query=x#fragment'" do
    @uri.route_from(
      "http://user:pass@example.com/path/to/resource?query=x#fragment"
    ).should == Addressable::URI.parse("#fragment")
  end
  
  it "should have a route of 'http://elsewhere.com/' to " +
      "'http://elsewhere.com/'" do
    @uri.route_to("http://elsewhere.com/").should ==
      Addressable::URI.parse("http://elsewhere.com/")
  end

  it "should have the correct scheme after assignment" do
    @uri.scheme = "ftp"
    @uri.scheme.should == "ftp"
    @uri.to_s.should ==
      "ftp://user:pass@example.com/path/to/resource?query=x#fragment"
  end
  
  it "should have the correct authority segment after assignment" do
    @uri.authority = "newuser:newpass@example.com:80"
    @uri.authority.should == "newuser:newpass@example.com:80"
    @uri.user.should == "newuser"
    @uri.password.should == "newpass"
    @uri.host.should == "example.com"
    @uri.port.should == 80
    @uri.specified_port.should == 80
    @uri.to_s.should == 
      "http://newuser:newpass@example.com:80" +
      "/path/to/resource?query=x#fragment"
  end

  it "should have the correct userinfo segment after assignment" do
    @uri.userinfo = "newuser:newpass"
    @uri.userinfo.should == "newuser:newpass"
    @uri.authority.should == "newuser:newpass@example.com"
    @uri.user.should == "newuser"
    @uri.password.should == "newpass"
    @uri.host.should == "example.com"
    @uri.port.should == 80
    @uri.specified_port.should == nil
    @uri.to_s.should ==
      "http://newuser:newpass@example.com" +
      "/path/to/resource?query=x#fragment"
  end

  it "should have the correct username after assignment" do
    @uri.user = "newuser"
    @uri.user.should == "newuser"
    @uri.authority.should == "newuser:pass@example.com"
  end

  it "should have the correct password after assignment" do
    @uri.password = "newpass"
    @uri.password.should == "newpass"
    @uri.authority.should == "user:newpass@example.com"
  end

  it "should have the correct host after assignment" do
    @uri.host = "newexample.com"
    @uri.host.should == "newexample.com"
    @uri.authority.should == "user:pass@newexample.com"
  end

  it "should have the correct port after assignment" do
    @uri.port = 8080
    @uri.port.should == 8080
    @uri.authority.should == "user:pass@example.com:8080"
  end

  it "should have the correct path after assignment" do
    @uri.path = "/newpath/to/resource"
    @uri.path.should == "/newpath/to/resource"
    @uri.to_s.should ==
      "http://user:pass@example.com/newpath/to/resource?query=x#fragment"
  end

  it "should have the correct query string after assignment" do
    @uri.query = "newquery=x"
    @uri.query.should == "newquery=x"
    @uri.to_s.should == 
      "http://user:pass@example.com/path/to/resource?newquery=x#fragment"
  end

  it "should have the correct fragment after assignment" do
    @uri.fragment = "newfragment"
    @uri.fragment.should == "newfragment"
    @uri.to_s.should ==
      "http://user:pass@example.com/path/to/resource?query=x#newfragment"
  end
end

describe Addressable::URI, " when parsed from " +
    "'http://user@example.com'" do
  before do
    @uri = Addressable::URI.parse("http://user@example.com")
  end

  it "should use the 'http' scheme" do
    @uri.scheme.should == "http"
  end

  it "should have a username of 'user'" do
    @uri.user.should == "user"
  end

  it "should have no password" do
    @uri.password.should == nil
  end
  
  it "should have a host of 'example.com'" do
    @uri.host.should == "example.com"
  end

  it "should use port 80" do
    @uri.port.should == 80
  end
  
  it "should have the correct username after assignment" do
    @uri.user = "newuser"
    @uri.user.should == "newuser"
    @uri.password.should == nil
    @uri.to_s.should == "http://newuser@example.com"
  end

  it "should have the correct password after assignment" do
    @uri.password = "newpass"
    @uri.password.should == "newpass"
    @uri.to_s.should == "http://user:newpass@example.com"
  end

  it "should have the correct userinfo segment after assignment" do
    @uri.userinfo = "newuser:newpass"
    @uri.userinfo.should == "newuser:newpass"
    @uri.user.should == "newuser"
    @uri.password.should == "newpass"
    @uri.host.should == "example.com"
    @uri.port.should == 80
    @uri.specified_port.should == nil
    @uri.to_s.should == "http://newuser:newpass@example.com"
  end

  it "should have the correct userinfo segment after nil assignment" do
    @uri.userinfo = nil
    @uri.userinfo.should == nil
    @uri.user.should == nil
    @uri.password.should == nil
    @uri.host.should == "example.com"
    @uri.port.should == 80
    @uri.specified_port.should == nil
    @uri.to_s.should == "http://example.com"
  end
  
  it "should have the correct authority segment after assignment" do
    @uri.authority = "newuser@example.com"
    @uri.authority.should == "newuser@example.com"
    @uri.user.should == "newuser"
    @uri.password.should == nil
    @uri.host.should == "example.com"
    @uri.port.should == 80
    @uri.specified_port.should == nil
    @uri.to_s.should == "http://newuser@example.com"
  end
  
  it "should raise an error after nil assignment of authority segment" do
    (lambda do
      # This would create an invalid URI
      @uri.authority = nil
    end).should raise_error
  end
end

describe Addressable::URI, " when parsed from " +
    "'http://user:@example.com'" do
  before do
    @uri = Addressable::URI.parse("http://user:@example.com")
  end

  it "should use the 'http' scheme" do
    @uri.scheme.should == "http"
  end

  it "should have a username of 'user'" do
    @uri.user.should == "user"
  end

  it "should have a password of ''" do
    @uri.password.should == ""
  end
  
  it "should have a host of 'example.com'" do
    @uri.host.should == "example.com"
  end

  it "should use port 80" do
    @uri.port.should == 80
  end

  it "should have the correct username after assignment" do
    @uri.user = "newuser"
    @uri.user.should == "newuser"
    @uri.password.should == ""
    @uri.to_s.should == "http://newuser:@example.com"
  end

  it "should have the correct password after assignment" do
    @uri.password = "newpass"
    @uri.password.should == "newpass"
    @uri.to_s.should == "http://user:newpass@example.com"
  end

  it "should have the correct authority segment after assignment" do
    @uri.authority = "newuser:@example.com"
    @uri.authority.should == "newuser:@example.com"
    @uri.user.should == "newuser"
    @uri.password.should == ""
    @uri.host.should == "example.com"
    @uri.port.should == 80
    @uri.specified_port.should == nil
    @uri.to_s.should == "http://newuser:@example.com"
  end
end

describe Addressable::URI, " when parsed from " +
    "'http://:pass@example.com'" do
  before do
    @uri = Addressable::URI.parse("http://:pass@example.com")
  end

  it "should use the 'http' scheme" do
    @uri.scheme.should == "http"
  end

  it "should have a username of ''" do
    @uri.user.should == ""
  end

  it "should have a password of 'pass'" do
    @uri.password.should == "pass"
  end

  it "should have a userinfo of ':pass'" do
    @uri.userinfo.should == ":pass"
  end
  
  it "should have a host of 'example.com'" do
    @uri.host.should == "example.com"
  end

  it "should use port 80" do
    @uri.port.should == 80
  end

  it "should have the correct username after assignment" do
    @uri.user = "newuser"
    @uri.user.should == "newuser"
    @uri.password.should == "pass"
    @uri.to_s.should == "http://newuser:pass@example.com"
  end

  it "should have the correct password after assignment" do
    @uri.password = "newpass"
    @uri.password.should == "newpass"
    @uri.user.should == ""
    @uri.to_s.should == "http://:newpass@example.com"
  end

  it "should have the correct authority segment after assignment" do
    @uri.authority = ":newpass@example.com"
    @uri.authority.should == ":newpass@example.com"
    @uri.user.should == ""
    @uri.password.should == "newpass"
    @uri.host.should == "example.com"
    @uri.port.should == 80
    @uri.specified_port.should == nil
    @uri.to_s.should == "http://:newpass@example.com"
  end
end

describe Addressable::URI, " when parsed from " +
    "'http://:@example.com'" do
  before do
    @uri = Addressable::URI.parse("http://:@example.com")
  end

  it "should use the 'http' scheme" do
    @uri.scheme.should == "http"
  end

  it "should have a username of ''" do
    @uri.user.should == ""
  end

  it "should have a password of ''" do
    @uri.password.should == ""
  end
  
  it "should have a host of 'example.com'" do
    @uri.host.should == "example.com"
  end

  it "should use port 80" do
    @uri.port.should == 80
  end

  it "should have the correct username after assignment" do
    @uri.user = "newuser"
    @uri.user.should == "newuser"
    @uri.password.should == ""
    @uri.to_s.should == "http://newuser:@example.com"
  end

  it "should have the correct password after assignment" do
    @uri.password = "newpass"
    @uri.password.should == "newpass"
    @uri.user.should == ""
    @uri.to_s.should == "http://:newpass@example.com"
  end

  it "should have the correct authority segment after assignment" do
    @uri.authority = ":@newexample.com"
    @uri.authority.should == ":@newexample.com"
    @uri.user.should == ""
    @uri.password.should == ""
    @uri.host.should == "newexample.com"
    @uri.port.should == 80
    @uri.specified_port.should == nil
    @uri.to_s.should == "http://:@newexample.com"
  end
end

describe Addressable::URI, " when parsed from " +
    "'#example'" do
  before do
    @uri = Addressable::URI.parse("#example")
  end

  it "should be considered relative" do
    @uri.should be_relative
  end

  it "should have a host of nil" do
    @uri.host.should == nil
  end

  it "should have a path of ''" do
    @uri.path.should == ""
  end

  it "should have a query string of nil" do
    @uri.query.should == nil
  end

  it "should have a fragment of 'example'" do
    @uri.fragment.should == "example"
  end
end

describe Addressable::URI, " when parsed from " +
    "the network-path reference '//example.com/'" do
  before do
    @uri = Addressable::URI.parse("//example.com/")
  end

  it "should be considered relative" do
    @uri.should be_relative
  end

  it "should have a host of 'example.com'" do
    @uri.host.should == "example.com"
  end

  it "should have a path of '/'" do
    @uri.path.should == "/"
  end
end

describe Addressable::URI, " when parsed from " +
    "'feed://http://example.com/'" do
  before do
    @uri = Addressable::URI.parse("feed://http://example.com/")
  end

  it "should have a path of 'http://example.com/'" do
    @uri.path.should == "http://example.com/"
  end

  it "should normalize to 'http://example.com/'" do
    @uri.normalize.to_s.should == "http://example.com/"
    @uri.normalize!.to_s.should == "http://example.com/"
  end
end

describe Addressable::URI, " when parsed from " +
    "'feed:http://example.com/'" do
  before do
    @uri = Addressable::URI.parse("feed:http://example.com/")
  end

  it "should have a path of 'http://example.com/'" do
    @uri.path.should == "http://example.com/"
  end

  it "should normalize to 'http://example.com/'" do
    @uri.normalize.to_s.should == "http://example.com/"
    @uri.normalize!.to_s.should == "http://example.com/"
  end
end

describe Addressable::URI, "when parsed from " +
    "'example://a/b/c/%7Bfoo%7D'" do
  before do
    @uri = Addressable::URI.parse("example://a/b/c/%7Bfoo%7D")
  end

  # Section 6.2.2 of RFC 3986
  it "should be equivalent to eXAMPLE://a/./b/../b/%63/%7bfoo%7d" do
    @uri.should ==
      Addressable::URI.parse("eXAMPLE://a/./b/../b/%63/%7bfoo%7d")
  end
end

describe Addressable::URI, " when parsed from " +
    "'http://example.com/indirect/path/./to/../resource/'" do
  before do
    @uri = Addressable::URI.parse(
      "http://example.com/indirect/path/./to/../resource/")
  end

  it "should use the 'http' scheme" do
    @uri.scheme.should == "http"
  end

  it "should have a host of 'example.com'" do
    @uri.host.should == "example.com"
  end

  it "should use port 80" do
    @uri.port.should == 80
  end

  it "should have a path of '/indirect/path/./to/../resource/'" do
    @uri.path.should == "/indirect/path/./to/../resource/"
  end

  # Section 6.2.2.3 of RFC 3986
  it "should have a normalized path of '/indirect/path/resource/'" do
    @uri.normalize.path.should == "/indirect/path/resource/"
    @uri.normalize!.path.should == "/indirect/path/resource/"
  end
end

describe Addressable::URI, " when parsed from " +
    "'http://under_score.example.com/'" do
  it "should not cause an error" do
    (lambda do
      Addressable::URI.parse("http://under_score.example.com/")
    end).should_not raise_error
  end
end

describe Addressable::URI, " when parsed from " +
    "'./this:that'" do
  before do
    @uri = Addressable::URI.parse("./this:that")
  end

  it "should be considered relative" do
    @uri.should be_relative
  end

  it "should have no scheme" do
    @uri.scheme.should == nil
  end
end

describe Addressable::URI, "when parsed from " +
    "'this:that'" do
  before do
    @uri = Addressable::URI.parse("this:that")
  end

  it "should be considered absolute" do
    @uri.should be_absolute
  end

  it "should have a scheme of 'this'" do
    @uri.scheme.should == "this"
  end
end

describe Addressable::URI, " when parsed from " +
    "'http://www.詹姆斯.com/'" do
  before do
    @uri = Addressable::URI.parse("http://www.詹姆斯.com/")
  end

  it "should be equivalent to 'http://www.xn--8ws00zhy3a.com/'" do
    if Addressable::URI::IDNA.send(:use_libidn?)
      @uri.should ==
        Addressable::URI.parse("http://www.xn--8ws00zhy3a.com/")
    else
      puts "\nSkipping IDN specification because GNU libidn is unavailable."
    end
  end

  it "should not have domain name encoded during normalization" do
    Addressable::URI.normalized_encode(@uri.to_s).should ==
      "http://www.詹姆斯.com/"
  end
end

describe Addressable::URI, " when parsed from " +
    "'http://www.詹姆斯.com/ some spaces /'" do
  before do
    @uri = Addressable::URI.parse("http://www.詹姆斯.com/ some spaces /")
  end

  it "should be equivalent to " +
      "'http://www.xn--8ws00zhy3a.com/%20some%20spaces%20/'" do
    if Addressable::URI::IDNA.send(:use_libidn?)
      @uri.should ==
        Addressable::URI.parse(
          "http://www.xn--8ws00zhy3a.com/%20some%20spaces%20/")
    else
      puts "\nSkipping IDN specification because GNU libidn is unavailable."
    end
  end

  it "should not have domain name encoded during normalization" do
    Addressable::URI.normalized_encode(@uri.to_s).should ==
      "http://www.詹姆斯.com/%20some%20spaces%20/"
  end
end

describe Addressable::URI, " when parsed from " +
    "'http://www.xn--8ws00zhy3a.com/'" do
  before do
    @uri = Addressable::URI.parse("http://www.xn--8ws00zhy3a.com/")
  end

  it "should be displayed as http://www.詹姆斯.com/" do
    if Addressable::URI::IDNA.send(:use_libidn?)
      @uri.display_uri.to_s.should == "http://www.詹姆斯.com/"
    else
      puts "\nSkipping IDN specification because GNU libidn is unavailable."
    end
  end
end

describe Addressable::URI, " when parsed from " +
    "'http://www.詹姆斯.com/atomtests/iri/詹.html'" do
  before do
    @uri = Addressable::URI.parse("http://www.詹姆斯.com/atomtests/iri/詹.html")
  end

  it "should normalize to " +
      "http://www.xn--8ws00zhy3a.com/atomtests/iri/%E8%A9%B9.html" do
    if Addressable::URI::IDNA.send(:use_libidn?)
      @uri.normalize.to_s.should ==
        "http://www.xn--8ws00zhy3a.com/atomtests/iri/%E8%A9%B9.html"
      @uri.normalize!.to_s.should ==
        "http://www.xn--8ws00zhy3a.com/atomtests/iri/%E8%A9%B9.html"
    else
      puts "\nSkipping IDN specification because GNU libidn is unavailable."
    end
  end
end

describe Addressable::URI, "with a base uri of 'http://a/b/c/d;p?q'" do
  before do
    @uri = Addressable::URI.parse("http://a/b/c/d;p?q")
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with 'g:h' should resolve to g:h" do
    (@uri + "g:h").to_s.should == "g:h"
    Addressable::URI.join(@uri, "g:h").to_s.should == "g:h"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with 'g' should resolve to http://a/b/c/g" do
    (@uri + "g").to_s.should == "http://a/b/c/g"
    Addressable::URI.join(@uri.to_s, "g").to_s.should == "http://a/b/c/g"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with './g' should resolve to http://a/b/c/g" do
    (@uri + "./g").to_s.should == "http://a/b/c/g"
    Addressable::URI.join(@uri.to_s, "./g").to_s.should == "http://a/b/c/g"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with 'g/' should resolve to http://a/b/c/g/" do
    (@uri + "g/").to_s.should == "http://a/b/c/g/"
    Addressable::URI.join(@uri.to_s, "g/").to_s.should == "http://a/b/c/g/"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with '/g' should resolve to http://a/g" do
    (@uri + "/g").to_s.should == "http://a/g"
    Addressable::URI.join(@uri.to_s, "/g").to_s.should == "http://a/g"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with '//g' should resolve to http://g" do
    (@uri + "//g").to_s.should == "http://g"
    Addressable::URI.join(@uri.to_s, "//g").to_s.should == "http://g"
  end
  
  # Section 5.4.1 of RFC 3986
  it "when joined with '?y' should resolve to http://a/b/c/d;p?y" do
    (@uri + "?y").to_s.should == "http://a/b/c/d;p?y"
    Addressable::URI.join(@uri.to_s, "?y").to_s.should == "http://a/b/c/d;p?y"
  end
  
  # Section 5.4.1 of RFC 3986
  it "when joined with 'g?y' should resolve to http://a/b/c/g?y" do
    (@uri + "g?y").to_s.should == "http://a/b/c/g?y"
    Addressable::URI.join(@uri.to_s, "g?y").to_s.should == "http://a/b/c/g?y"
  end
  
  # Section 5.4.1 of RFC 3986
  it "when joined with '#s' should resolve to http://a/b/c/d;p?q#s" do
    (@uri + "#s").to_s.should == "http://a/b/c/d;p?q#s"
    Addressable::URI.join(@uri.to_s, "#s").to_s.should == "http://a/b/c/d;p?q#s"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with 'g#s' should resolve to http://a/b/c/g#s" do
    (@uri + "g#s").to_s.should == "http://a/b/c/g#s"
    Addressable::URI.join(@uri.to_s, "g#s").to_s.should == "http://a/b/c/g#s"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with 'g?y#s' should resolve to http://a/b/c/g?y#s" do
    (@uri + "g?y#s").to_s.should == "http://a/b/c/g?y#s"
    Addressable::URI.join(
      @uri.to_s, "g?y#s").to_s.should == "http://a/b/c/g?y#s"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with ';x' should resolve to http://a/b/c/;x" do
    (@uri + ";x").to_s.should == "http://a/b/c/;x"
    Addressable::URI.join(@uri.to_s, ";x").to_s.should == "http://a/b/c/;x"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with 'g;x' should resolve to http://a/b/c/g;x" do
    (@uri + "g;x").to_s.should == "http://a/b/c/g;x"
    Addressable::URI.join(@uri.to_s, "g;x").to_s.should == "http://a/b/c/g;x"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with 'g;x?y#s' should resolve to http://a/b/c/g;x?y#s" do
    (@uri + "g;x?y#s").to_s.should == "http://a/b/c/g;x?y#s"
    Addressable::URI.join(
      @uri.to_s, "g;x?y#s").to_s.should == "http://a/b/c/g;x?y#s"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with '' should resolve to http://a/b/c/d;p?q" do
    (@uri + "").to_s.should == "http://a/b/c/d;p?q"
    Addressable::URI.join(@uri.to_s, "").to_s.should == "http://a/b/c/d;p?q"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with '.' should resolve to http://a/b/c/" do
    (@uri + ".").to_s.should == "http://a/b/c/"
    Addressable::URI.join(@uri.to_s, ".").to_s.should == "http://a/b/c/"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with './' should resolve to http://a/b/c/" do
    (@uri + "./").to_s.should == "http://a/b/c/"
    Addressable::URI.join(@uri.to_s, "./").to_s.should == "http://a/b/c/"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with '..' should resolve to http://a/b/" do
    (@uri + "..").to_s.should == "http://a/b/"
    Addressable::URI.join(@uri.to_s, "..").to_s.should == "http://a/b/"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with '../' should resolve to http://a/b/" do
    (@uri + "../").to_s.should == "http://a/b/"
    Addressable::URI.join(@uri.to_s, "../").to_s.should == "http://a/b/"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with '../g' should resolve to http://a/b/g" do
    (@uri + "../g").to_s.should == "http://a/b/g"
    Addressable::URI.join(@uri.to_s, "../g").to_s.should == "http://a/b/g"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with '../..' should resolve to http://a/" do
    (@uri + "../..").to_s.should == "http://a/"
    Addressable::URI.join(@uri.to_s, "../..").to_s.should == "http://a/"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with '../../' should resolve to http://a/" do
    (@uri + "../../").to_s.should == "http://a/"
    Addressable::URI.join(@uri.to_s, "../../").to_s.should == "http://a/"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with '../../g' should resolve to http://a/g" do
    (@uri + "../../g").to_s.should == "http://a/g"
    Addressable::URI.join(@uri.to_s, "../../g").to_s.should == "http://a/g"
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with '../../../g' should resolve to http://a/g" do
    (@uri + "../../../g").to_s.should == "http://a/g"
    Addressable::URI.join(@uri.to_s, "../../../g").to_s.should == "http://a/g"
  end

  it "when joined with '../.././../g' should resolve to http://a/g" do
    (@uri + "../.././../g").to_s.should == "http://a/g"
    Addressable::URI.join(@uri.to_s, "../.././../g").to_s.should == "http://a/g"
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with '../../../../g' should resolve to http://a/g" do
    (@uri + "../../../../g").to_s.should == "http://a/g"
    Addressable::URI.join(
      @uri.to_s, "../../../../g").to_s.should == "http://a/g"
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with '/./g' should resolve to http://a/g" do
    (@uri + "/./g").to_s.should == "http://a/g"
    Addressable::URI.join(@uri.to_s, "/./g").to_s.should == "http://a/g"
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with '/../g' should resolve to http://a/g" do
    (@uri + "/../g").to_s.should == "http://a/g"
    Addressable::URI.join(@uri.to_s, "/../g").to_s.should == "http://a/g"
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with 'g.' should resolve to http://a/b/c/g." do
    (@uri + "g.").to_s.should == "http://a/b/c/g."
    Addressable::URI.join(@uri.to_s, "g.").to_s.should == "http://a/b/c/g."
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with '.g' should resolve to http://a/b/c/.g" do
    (@uri + ".g").to_s.should == "http://a/b/c/.g"
    Addressable::URI.join(@uri.to_s, ".g").to_s.should == "http://a/b/c/.g"
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with 'g..' should resolve to http://a/b/c/g.." do
    (@uri + "g..").to_s.should == "http://a/b/c/g.."
    Addressable::URI.join(@uri.to_s, "g..").to_s.should == "http://a/b/c/g.."
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with '..g' should resolve to http://a/b/c/..g" do
    (@uri + "..g").to_s.should == "http://a/b/c/..g"
    Addressable::URI.join(@uri.to_s, "..g").to_s.should == "http://a/b/c/..g"
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with './../g' should resolve to http://a/b/g" do
    (@uri + "./../g").to_s.should == "http://a/b/g"
    Addressable::URI.join(@uri.to_s, "./../g").to_s.should == "http://a/b/g"
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with './g/.' should resolve to http://a/b/c/g/" do
    (@uri + "./g/.").to_s.should == "http://a/b/c/g/"
    Addressable::URI.join(@uri.to_s, "./g/.").to_s.should == "http://a/b/c/g/"
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with 'g/./h' should resolve to http://a/b/c/g/h" do
    (@uri + "g/./h").to_s.should == "http://a/b/c/g/h"
    Addressable::URI.join(@uri.to_s, "g/./h").to_s.should == "http://a/b/c/g/h"
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with 'g/../h' should resolve to http://a/b/c/h" do
    (@uri + "g/../h").to_s.should == "http://a/b/c/h"
    Addressable::URI.join(@uri.to_s, "g/../h").to_s.should == "http://a/b/c/h"
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with 'g;x=1/./y' " +
      "should resolve to http://a/b/c/g;x=1/y" do
    (@uri + "g;x=1/./y").to_s.should == "http://a/b/c/g;x=1/y"
    Addressable::URI.join(
      @uri.to_s, "g;x=1/./y").to_s.should == "http://a/b/c/g;x=1/y"
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with 'g;x=1/../y' should resolve to http://a/b/c/y" do
    (@uri + "g;x=1/../y").to_s.should == "http://a/b/c/y"
    Addressable::URI.join(
      @uri.to_s, "g;x=1/../y").to_s.should == "http://a/b/c/y"
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with 'g?y/./x' " +
      "should resolve to http://a/b/c/g?y/./x" do
    (@uri + "g?y/./x").to_s.should == "http://a/b/c/g?y/./x"
    Addressable::URI.join(
      @uri.to_s, "g?y/./x").to_s.should == "http://a/b/c/g?y/./x"
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with 'g?y/../x' " +
      "should resolve to http://a/b/c/g?y/../x" do
    (@uri + "g?y/../x").to_s.should == "http://a/b/c/g?y/../x"
    Addressable::URI.join(
      @uri.to_s, "g?y/../x").to_s.should == "http://a/b/c/g?y/../x"
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with 'g#s/./x' " +
      "should resolve to http://a/b/c/g#s/./x" do
    (@uri + "g#s/./x").to_s.should == "http://a/b/c/g#s/./x"
    Addressable::URI.join(
      @uri.to_s, "g#s/./x").to_s.should == "http://a/b/c/g#s/./x"
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with 'g#s/../x' " +
      "should resolve to http://a/b/c/g#s/../x" do
    (@uri + "g#s/../x").to_s.should == "http://a/b/c/g#s/../x"
    Addressable::URI.join(
      @uri.to_s, "g#s/../x").to_s.should == "http://a/b/c/g#s/../x"
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with 'http:g' should resolve to http:g" do
    (@uri + "http:g").to_s.should == "http:g"
    Addressable::URI.join(@uri.to_s, "http:g").to_s.should == "http:g"
  end

  # Edge case to be sure
  it "when joined with '//example.com/' should " +
      "resolve to http://example.com/" do
    (@uri + "//example.com/").to_s.should == "http://example.com/"
    Addressable::URI.join(
      @uri.to_s, "//example.com/").to_s.should == "http://example.com/"
  end
end

describe Addressable::URI::IDNA, "without libidn bindings" do
  before do
    Addressable::URI::IDNA.instance_variable_set("@use_libidn", false)
  end
  
  it "should raise an exception when an operation is attempted" do
    (lambda do
      Addressable::URI::IDNA.to_ascii("www.詹姆斯.com")
    end).should raise_error
    (lambda do
      Addressable::URI::IDNA.to_unicode("www.xn--8ws00zhy3a.com")
    end).should raise_error
  end

  it "should not cause normalization routines to error out" do
    (lambda do
      uri = Addressable::URI.parse(
        "http://www.詹姆斯.com/atomtests/iri/詹.html")
      uri.normalize
    end).should_not raise_error
  end

  it "should not cause display uri routines to error out" do
    (lambda do
      uri = Addressable::URI.parse(
        "http://www.xn--8ws00zhy3a.com/atomtests/iri/%E8%A9%B9.html")
      uri.display_uri
    end).should_not raise_error
  end
  
  after do
    Addressable::URI::IDNA.instance_variable_set("@use_libidn", nil)
    Addressable::URI::IDNA.send(:use_libidn?)
  end
end

describe Addressable::URI::IDNA, "with rubygems and idn missing" do
  before do
    module Kernel
      alias_method :saved_require, :require
      def require(path)
        raise LoadError,
          "Libraries cannot be loaded during this test."
      end
    end
    Addressable::URI::IDNA.instance_variable_set("@use_libidn", nil)
  end
  
  it "should not raise an exception while checking " +
      "if libidn is available" do
    (lambda do
      Addressable::URI::IDNA.send(:use_libidn?)
    end).should_not raise_error
  end

  it "should not cause normalization routines to error out" do
    (lambda do
      uri = Addressable::URI.parse(
        "http://www.詹姆斯.com/atomtests/iri/詹.html")
      uri.normalize
    end).should_not raise_error
  end

  it "should not cause display uri routines to error out" do
    (lambda do
      uri = Addressable::URI.parse(
        "http://www.xn--8ws00zhy3a.com/atomtests/iri/%E8%A9%B9.html")
      uri.display_uri
    end).should_not raise_error
  end
  
  after do
    module Kernel
      def require(path)
        saved_require(path)
      end
      alias_method :require, :saved_require
    end
    Addressable::URI::IDNA.instance_variable_set("@use_libidn", nil)
    Addressable::URI::IDNA.send(:use_libidn?)
  end
end

describe Addressable::URI, "when extracting from an arbitrary text" do
  before do
    @text = File.open(File.expand_path(
      File.dirname(__FILE__) + "/../data/rfc3986.txt")) { |file| file.read }
  end

  it "should have all obvious URIs extractable from it" do
    @uris = Addressable::URI.extract(@text)
    @uris.should include("http://www.w3.org/People/Berners-Lee/")
    @uris.should include("http://roy.gbiv.com/")
    @uris.should include("http://larry.masinter.net/")
    @uris = Addressable::URI.extract(@text,
      :base => "http://example.com/", :parse => true)
    @uris.should include(
      Addressable::URI.parse("http://www.w3.org/People/Berners-Lee/"))
    @uris.should include(
      Addressable::URI.parse("http://roy.gbiv.com/"))
    @uris.should include(
      Addressable::URI.parse("http://larry.masinter.net/"))
  end
end

describe Addressable::URI, "when extracting from an arbitrary text " +
    "containing invalid URIs" do
  before do
    @text = <<-TEXT
      This is an invalid URI:
        http://example.com:bogus/path/to/something/
      This is a valid URI:
        http://example.com:80/path/to/something/
    TEXT
  end

  it "should ignore invalid URIs when extracting" do
    @uris = Addressable::URI.extract(@text)
    @uris.should include("http://example.com:80/path/to/something/")
    @uris.should_not include("http://example.com:bogus/path/to/something/")
    @uris.size.should == 1
  end
end

describe Addressable::URI, "when converting the path " +
    "'relative/path/to/something'" do
  before do
    @path = 'relative/path/to/something'
  end

  it "should convert to " +
      "\'relative/path/to/something\'" do
    @uri = Addressable::URI.convert_path(@path)
    @uri.to_s.should == "relative/path/to/something"
  end
end

describe Addressable::URI, "when given the root directory" do
  before do
    if RUBY_PLATFORM =~ /mswin/
      @path = "C:\\"
    else
      @path = "/"
    end
  end

  if RUBY_PLATFORM =~ /mswin/
    it "should convert to \'file:///c:/\'" do
      @uri = Addressable::URI.convert_path(@path)
      @uri.to_s.should == "file:///c:/"
    end
  else
    it "should convert to \'file:///\'" do
      @uri = Addressable::URI.convert_path(@path)
      @uri.to_s.should == "file:///"
    end
  end
end

describe Addressable::URI, "when given the path '/home/user/'" do
  before do
    @path = '/home/user/'
  end

  it "should convert to " +
      "\'file:///home/user/\'" do
    @uri = Addressable::URI.convert_path(@path)
    @uri.to_s.should == "file:///home/user/"
  end
end

describe Addressable::URI, " when given the path " +
    "'c:\\windows\\My Documents 100%20\\foo.txt'" do
  before do
    @path = "c:\\windows\\My Documents 100%20\\foo.txt"
  end

  it "should convert to " +
      "\'file:///c:/windows/My%20Documents%20100%20/foo.txt\'" do
    @uri = Addressable::URI.convert_path(@path)
    @uri.to_s.should == "file:///c:/windows/My%20Documents%20100%20/foo.txt"
  end
end

describe Addressable::URI, " when given the path " +
    "'file://c:\\windows\\My Documents 100%20\\foo.txt'" do
  before do
    @path = "file://c:\\windows\\My Documents 100%20\\foo.txt"
  end

  it "should convert to " +
      "\'file:///c:/windows/My%20Documents%20100%20/foo.txt\'" do
    @uri = Addressable::URI.convert_path(@path)
    @uri.to_s.should == "file:///c:/windows/My%20Documents%20100%20/foo.txt"
  end
end

describe Addressable::URI, " when given the path " +
    "'file:///c|/windows/My%20Documents%20100%20/foo.txt'" do
  before do
    @path = "file:///c|/windows/My%20Documents%20100%20/foo.txt"
  end

  it "should convert to " +
      "\'file:///c:/windows/My%20Documents%20100%20/foo.txt\'" do
    @uri = Addressable::URI.convert_path(@path)
    @uri.to_s.should == "file:///c:/windows/My%20Documents%20100%20/foo.txt"
  end
end

describe Addressable::URI, "when given an http protocol URI" do
  before do
    @path = "http://example.com/"
  end

  it "should not do any conversion at all" do
    @uri = Addressable::URI.convert_path(@path)
    @uri.to_s.should == "http://example.com/"
  end
end

describe Addressable::URI, " when given the template pattern " +
    "'http://example.com/search/{query}/' " +
    "to be processed with the ExampleProcessor" do
  before do
    @pattern = "http://example.com/search/{query}/"
  end

  it "should expand to " +
      "'http://example.com/search/an+example+search+query/' " +
      "with a mapping of {\"query\" => \"an example search query\"} " do
    Addressable::URI.expand_template(
      "http://example.com/search/{query}/",
      {"query" => "an example search query"},
      ExampleProcessor).to_s.should ==
        "http://example.com/search/an+example+search+query/"
  end

  it "should raise an error " +
      "with a mapping of {\"query\" => \"invalid!\"}" do
    (lambda do
      Addressable::URI.expand_template(
        "http://example.com/search/{query}/",
        {"query" => "invalid!"},
        ExampleProcessor).to_s
    end).should raise_error
  end
end

# Section 3.3.1 of the URI Template draft
describe Addressable::URI, " when given the mapping supplied in " +
    "Section 3.3.1 of the URI Template draft" do
  before do
    @mapping = {
      "a" => "fred",
      "b" => "barney",
      "c" => "cheeseburger",
      "d" => "one two three",
      "e" => "20% tricky",
      "f" => "",
      "20" => "this-is-spinal-tap",
      "scheme" => "https",
      "p" => "quote=to+be+or+not+to+be",
      "q" => "hullo#world"
    }
  end
  
  it "should result in 'http://example.org/page1#fred' " +
      "when used to expand 'http://example.org/page1\#{a}'" do
    Addressable::URI.expand_template(
      "http://example.org/page1\#{a}",
      @mapping).to_s.should == "http://example.org/page1#fred"
  end
  
  it "should result in 'http://example.org/fred/barney/' " +
      "when used to expand 'http://example.org/{a}/{b}/'" do
    Addressable::URI.expand_template(
      "http://example.org/{a}/{b}/",
      @mapping).to_s.should == "http://example.org/fred/barney/"
  end
  
  it "should result in 'http://example.org/fredbarney/' " +
      "when used to expand 'http://example.org/{a}{b}/'" do
    Addressable::URI.expand_template(
      "http://example.org/{a}{b}/",
      @mapping).to_s.should == "http://example.org/fredbarney/"
  end
  
  it "should result in " +
      "'http://example.com/order/cheeseburger/cheeseburger/cheeseburger/' " +
      "when used to expand 'http://example.com/order/{c}/{c}/{c}/'" do
    Addressable::URI.expand_template(
      "http://example.com/order/{c}/{c}/{c}/",
      @mapping).to_s.should ==
        "http://example.com/order/cheeseburger/cheeseburger/cheeseburger/"
  end
  
  it "should result in 'http://example.org/one%20two%20three' " +
      "when used to expand 'http://example.org/{d}'" do
    Addressable::URI.expand_template(
      "http://example.org/{d}",
      @mapping).to_s.should == "http://example.org/one%20two%20three"
  end
  
  it "should result in 'http://example.org/20%25%20tricky' " +
      "when used to expand 'http://example.org/{e}'" do
    Addressable::URI.expand_template(
      "http://example.org/{e}",
      @mapping).to_s.should == "http://example.org/20%25%20tricky"
  end
  
  it "should result in 'http://example.com//' " +
      "when used to expand 'http://example.com/{f}/'" do
    Addressable::URI.expand_template(
      "http://example.com/{f}/",
      @mapping).to_s.should == "http://example.com//"
  end
  
  it "should result in " +
      "'https://this-is-spinal-tap.example.org?date=&option=fred' " +
      "when used to expand " +
      "'{scheme}://{20}.example.org?date={wilma}&option={a}'" do
    Addressable::URI.expand_template(
      "{scheme}://{20}.example.org?date={wilma}&option={a}",
      @mapping).to_s.should ==
        "https://this-is-spinal-tap.example.org?date=&option=fred"
  end
  
  it "should result in 'http://example.org?quote=to+be+or+not+to+be' " +
      "when used to expand 'http://example.org?{p}'" do
    Addressable::URI.expand_template(
      "http://example.org?{p}",
      @mapping).to_s.should == "http://example.org?quote=to+be+or+not+to+be"
  end
  
  it "should result in 'http://example.com/hullo#world' " +
      "when used to expand 'http://example.com/{q}'" do
    Addressable::URI.expand_template(
      "http://example.com/{q}",
      @mapping).to_s.should == "http://example.com/hullo#world"
  end
end

describe Addressable::URI, "when given a mapping that contains a " +
  "template-var within a value" do
  before do
    @mapping = {
      "a" => "{b}",
      "b" => "barney",
    }
  end
  
  it "should result in 'http://example.com/%7Bb%7D/barney/' " +
      "when used to expand 'http://example.com/{a}/{b}/'" do
    Addressable::URI.expand_template(
      "http://example.com/{a}/{b}/",
      @mapping).to_s.should == "http://example.com/%7Bb%7D/barney/"
  end
end

describe Addressable::URI, "when given a mapping that contains values " +
    "that are already percent-encoded" do
  before do
    @mapping = {
      "a" => "%7Bb%7D"
    }
  end
  
  it "should result in 'http://example.com/%257Bb%257D/' " +
      "when used to expand 'http://example.com/{a}/'" do
    Addressable::URI.expand_template(
      "http://example.com/{a}/",
      @mapping).to_s.should == "http://example.com/%257Bb%257D/"
  end
end

describe Addressable::URI, " when parsed from " +
    "'http://example.com/search/an+example+search+query/'" do
  before do
    @uri = Addressable::URI.parse(
      "http://example.com/search/an+example+search+query/")
  end
  
  it "should have the correct mapping when extracting values using " +
      "the pattern 'http://example.com/search/{query}/' with the " +
      "ExampleProcessor" do
    @uri.extract_mapping(
      "http://example.com/search/{query}/", ExampleProcessor
    ).should == {
      "query" => "an example search query"
    }
  end
  
  it "should return nil when extracting values using " +
      "a non-matching pattern" do
    @uri.extract_mapping(
      "http://bogus.com/{thingy}/"
    ).should == nil
  end
end

describe Addressable::URI, " when parsed from " +
    "'http://example.com/a/b/c/'" do
  before do
    @uri = Addressable::URI.parse(
      "http://example.com/a/b/c/")
  end
  
  it "should have the correct mapping when extracting values " +
      "using the pattern " +
      "'http://example.com/{first}/{second}/' with the ExampleProcessor" do
    @uri.extract_mapping(
      "http://example.com/{first}/{second}/", ExampleProcessor
    ).should == {
      "first" => "a",
      "second" => "b/c"
    }
  end
end

describe Addressable::URI, " when parsed from " +
    "'http://example.com/one/spacer/two/'" do
  before do
    @uri = Addressable::URI.parse("http://example.com/one/spacer/two/")
  end
  
  it "should have the correct mapping when extracting values " +
      "using the pattern " +
      "'http://example.com/{first}/spacer/{second}/'" do
    @uri.extract_mapping(
      "http://example.com/{first}/spacer/{second}/").should == {
        "first" => "one",
        "second" => "two"
      }
  end
end