#encoding: UTF-8
require "execjs"

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
    path ||= File.join("coffee","coffee-script.js")
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

    def coffee_script_compile todo
      context = ExecJS.compile(compiler_path)
      js = context.call("CoffeeScript.compile", todo, :bare => true)
      javascript_compile(js)
    end

    def javascript_compile todo
        Dir.mkdir("extension") unless File.exists?("extension")
        s = File.new(File.join("extension",filename),'w+')
        s.write(todo)
    end

  end

end

