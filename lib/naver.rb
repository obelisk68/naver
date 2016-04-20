require "naver/version"
require 'nokogiri' 
require 'open-uri'
#require 'utils'

module Naver
  def self.getpic(num, dir=".")
    GetPic.new.main(num, dir)
  end
  
  class GetPic        
    def main(number, dir)
      Dir.chdir(dir)
      @number = number
      url = 'http://matome.naver.jp/odai/' + @number.to_s + '?page='
      i = 1; @num = 1; @rsv = ""
      Dir.mkdir(@number.to_s); Dir.chdir(@number.to_s)
      loop do
	puts "\npage#{i}"
	url1 = url + i.to_s
	return unless getpage(url1)
	i += 1
      end
    end
    
    private
    def imgsuffix(st)
      [".jpg", ".gif", ".png", ".jpeg", ".bmp", ".JPG", ".GIF", ".PNG", ".JPEG", ".BMP"].each do |sf|
        return sf if st.include?(sf)
      end
      ""
    end
    
    def save_file(url, filename)
      begin
	open(filename, 'wb') do |file|
	  open(url) {|data| file.write(data.read)}
	end
	true 
      rescue
	puts "File error： " + $!.message
      end
    end
    
    def time_lexic
    t = Time.now
    i = (t.to_i.to_s +  sprintf("%06d", t.usec)).to_i
    ar = ("a".."z").to_a
    st = ""
    begin
      st = ar[i % 26] + st
      i /= 26
    end while i > 0
    st
  end
    
    
    def getpage(url)
      check = true
      Nokogiri.HTML(open(url)).css('p.mdMTMWidget01ItemImg01View a').each do |node|
	url1 = node.attribute('href').value
	if check
	  if @rsv == url1
	    puts "end"
	    return false
	  else
	    @rsv = url1
	    check = false
	  end
	end
	dlpic(url1) 
      end
      true
    end
    
    def dlpic(url)
      iurl = Nokogiri.HTML(open(url)).css('p.mdMTMEnd01Img01 a').attribute('href').value
      fname = time_lexic + imgsuffix(iurl)
      if save_file(iurl, fname)
	print "Success:  "
	@num += 1
      else
	File.delete(fname)
      end
    rescue
      print "error:  "
    end
  end
end

