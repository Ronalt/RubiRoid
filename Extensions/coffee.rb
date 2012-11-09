#encoding: UTF-8
require "execjs"
require "open-uri"

module Opera

  class JSiCO

  def initialize lg = nil,ph = nil,fe = nil
     language lg
     compiler_path ph
     filename fe
  end

  def language lang = nil
    @lang = lang if lang
    @lang
  end

  def compiler_path path = nil
    @path = path if path
    @path
  end

  def filename file = nil
    @filename = file if file
    @filename
  end

   def compile todo
     send "#{@lang.to_s}_compile".to_sym , todo
   end

    private

    def prepare ptp
      if ptp =~ /^(http|https|ftp):\/\/([0-9a-z\.]+)(\/([0-9a-z\.]+))*/
	  nas = open(ptp).read
	  s = File.join("coffee","user-coffee-compiler.js")
	  File.new(s,"w+").write(nas)
	  compiler_path(s)
	  return nas 
      elsif ptp
	  File.open(ptp,"r").read
	  else
	  File.open(File.join("coffee","coffee-script.js"),"r").read
	  end
	end

    def coffee_script_compile todo
      red = prepare(compiler_path)
      js = ExecJS.compile(red).call("CoffeeScript.compile",todo, bare: true)
      javascript_compile(js)
    end

    def javascript_compile todo
        Dir.mkdir("extension") unless File.exists?("extension")
        s = File.new(File.join("extension",filename),'w+')
        s.write(todo)
    end

  end
end

