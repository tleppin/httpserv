#!/usr/bin/ruby -w
# written by Thorsten Leppin thorsten.leppin@web.de
# December 14. 2017
# A very simple, hardwired, procedural HTTP1.1 minimal webserver 
# Based on code found in extracts of "Programming Ruby - The Pragmatic Programmer's Guide" Copyright © 2000 Addison Wesley Longman, Inc. 
# The aforementioned extracts are released under the terms of the Open Publication License V1.0. Downloaded from: http://www.pragmaticprogrammer.com/ruby/downloads/book.html 

require 'socket'
# CHANGE THESE AS APPLICABLE:
DOCROOT = "/home/user/doc/"
HOSTIPV4 = "192.168.50.96"
DEFAULTPAGE = "index.html"

# functions START
def htdocument(filename)
  thefile = File.open(DOCROOT + filename, "r")
  output = Array.new()
  thefile.each { |line| output.push(line) }
  return output.join
end

# given a TCPServer accepted session delivers a resource (located in DOCROOT directory) by pagename returning code 200 to client
def pageserve(pagename, httpsession)
  extension = pagename.split(".").last.downcase
  case extension
    when "htm", "html"
    contenttype = "text/html"
    when "xml"
    contenttype = "text/xml"
    when "txt", "utf-8"
    contenttype = "text/plain"
    when "css"
    contenttype = "text/css"
    when "js"
    contenttype = "text/javascript"
    when "jpg", "jpe", "jpeg", "png", "gif", "ico", "tiff", "wbmp"
    contenttype = "image/#{extension}"
    else
    contenttype = "application/#{extension}"
  end
  httpheader(httpsession, 200, contenttype)
  httpsession.print htdocument(pagename)
  httpsession.close
end

# given a TCPServer accepted session and valid 3-digit codenumber prints HTTP header with according statuscode 
def httpheader(session, code, contenttype)
  thissession = session
  returncodes = {
  200 => "200/OK",
  404 => "404/NOT FOUND"
  }
  thissession.print "HTTP/1.1 #{returncodes[code]}\r\nContent-type: #{contenttype}\r\n\r\n"
end

# given a TCPServer accepted session returns code 404 to client in case of unavailable URL
def pagenotfound(httpsession)
  httpheader(httpsession, 404, "text/html")
  httpsession.print "<!DOCTYPE HTML><html><head><meta http-equiv='content-type' content='text/html; charset=UTF-8'><title>404 - Page Not Available</title></head><body><h1>404 - Page Not Available</h1></body></html>"
  httpsession.close
end
# functions END

serverport = (ARGV[0] || 80).to_i
puts "Listening on port #{serverport} for HTTP connections."
httpserver = TCPServer.new(HOSTIPV4, serverport)
puts "Host is: #{HOSTIPV4}"
# main processing loop
while (httpsession = httpserver.accept)
  clientrequest = httpsession.gets
  requestv = clientrequest.split(" ")
  puts "Request: #{clientrequest}"
  if clientrequest.chomp == "GET / HTTP/1.1"
    pageserve(DEFAULTPAGE, httpsession)
  else
    unless !File.exists?(DOCROOT.chop + requestv[1])
      pageserve(requestv[1], httpsession)
    else
      pagenotfound(httpsession)
    end
  end
end
