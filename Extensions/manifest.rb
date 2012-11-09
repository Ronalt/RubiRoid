#encoding: UTF-8
require "rexml/document"

module Opera

  class Manifest

    include REXML

    def initialize args = nil
      @lang = {}
      Manifest::init_func

      if args
        [:name, :author, :description, :icon].map { |it|
          fail "Couldn`t initialize object" unless args.member? it
        }
        args.each { |key,value|
          send %Q(#{key}).to_sym,value
        }
      end
    end

    def config &block
      instance_eval &block if block_given?
    end

    def method_missing m_name,*args,&block
     if m_name =~ /^(.+)_(.+)$/ &&  %w!author description name license!.member?($1)
      meth = "#{$1}_#{$2}"
      self.class.send :define_method, meth, lambda{ |val = nil|
         return instance_variable_set %Q!@#{meth}!,val unless val.nil?
         instance_variable_get %Q!@#{meth}!
      }
       self.send meth.to_sym, args[0]
     else
      super(m_name,args,&block)
     end
    end

    def create

      [:author, :description, :name, :license].collect do |var|
        x = (eval("@#{var.to_s}_lang"))
        @lang[var] = x
      end

      doc = Document.new
      doc << XMLDecl.new("1.0", "utf-8")
      r = doc.add_element "widget", {"xmlns" => "http://www.w3.org/ns/widgets"}

      r.class.class_eval do
        def add_attribute_if_not_nil *args, &block
          add_attribute *args if args[1]
        end
      end

      r.add_attribute_if_not_nil "id", @widget_id
      r.add_attribute_if_not_nil "version", @widget_version

      %w!name author description!.each do  |nd|
      fail "Couldn`t create manifest. Specify #{nd} of the extension `"  unless eval "@#{nd}"
      end

      create_name = lambda do |per|
        if self.send per
        name = r.add_element "name"
        name.text = self.send per
        name.add_attribute_if_not_nil "short", eval("@#{per}_short")
        name
        end
        end

      create_author = lambda do |per|
       if self.send per
      author = r.add_element "author"
      author.text = self.send per
      author.add_attribute_if_not_nil "email", eval("@#{per}_email")
      author.add_attribute_if_not_nil "href", eval("@#{per}_href")
      author
       end
       end

      create_description = lambda do |per|
      x = send per
      if x && (!x.respond_to?(:call))
      description = r.add_element "description"
      description.text = x
      description
      end
      end

      create_license = lambda do |per|
       if self.send per
        license = r.add_element "license"
        license.text = self.send per
        license.add_attribute_if_not_nil "href", eval("@#{per}_href")
        license
      end
      end

        %w!name author license description!.map do |tag|
        unless  @lang[tag.to_sym]
        pro_t = eval("create_#{tag}")
        pro_t.call(tag)
        else
        pro = eval("create_#{tag}")
        xml_ = pro.call tag
        xml_.add_attribute "xml:lang", "en" if xml_
       if @lang[tag.to_sym].class.to_s == "Array"
		  @lang[tag.to_sym].each do |lang|
              lang = lang.to_s
              xml_l = eval("create_#{tag}")
              res = xml_l.("#{tag}_#{lang}")
              res.add_attribute "xml:lang", lang if res
              end
		else
		 l = @lang[tag.to_sym].to_s
         xm_ = eval("create_#{tag}")
         ri = xm_.("#{tag}_#{l}")
         ri.add_attribute "xml:lang", l if ri
		end
        end
		end

      fail "Couldn`t create manifest. Specify path to the icon(64x64) of the extension `" unless @icon
      icon = r.add_element "icon"
      icon.add_attribute_if_not_nil "src", @icon

      %w!accesse preference feature!.map do |mass|
	    lss = eval("@#{mass}s")
	    if lss && (lss.class.to_s == "Array")
         lss.each do |_lss|
           send "set_#{mass}".to_sym, _lss, r
         end
        elsif lss
		   send "set_#{mass}".to_sym, lss, r
	    end
      end

	  create_file(doc)
   end

	def langs *as
	 %w[author description name license].collect do |var|
	  x = instance_variable_get "@#{var}_lang"
	  s = ([as,x].flatten).uniq if x
	  s ||= as
	  instance_variable_set %Q!@#{var}_lang!,s
    end
	end

	private

	def create_file xml
	 Dir.mkdir("extension") unless File.exists?("extension")
     s = File.new(File.join("extension","config.xml"),'w+')
     xml.write(s,0)
    end

	def set_accesse _access,r
	if  _access[:origin]
         access = r.add_element "access"
         access.add_attribute "origin", _access[:origin]
         access.add_attribute_if_not_nil "subdomains", _access[:subdomains]
       end
	end

	def set_preference _preference,r
	    if _preference[:name] && _preference[:value]
           preference = r.add_element "preference"
           preference.add_attribute "name", _preference[:name]
           preference.add_attribute "value", _preference[:value]
           preference.add_attribute_if_not_nil "readonly", _preference[:readonly]
       end
    end

	def set_feature _feature,r
	   if  _feature[:name]
         feature = r.add_element "feature"
         feature.add_attribute "name", _feature[:name]
         feature.add_attribute_if_not_nil "required", _feature[:required]
          if _feature[:name] == "opera:speed_dial"
           param = feature.add_element "param"
           param.add_attribute "name", "url"
           param.add_attribute "value", _feature[:speed_dial]
         end
        end
	  end

    def self.init_func
      @all =  [:name,:name_short]
      @all << [:author, :author_email, :author_href]
      @all << [:description]
      @all << [:author_lang, :description_lang, :name_lang, :license_lang]
	    @all << [:accesses]
      @all << [:features]
	    @all << [:preferences]
	    @all << [:widget_id, :widget_version]
      @all << [:icon]
      @all << [:license, :license_href]
      @all.flatten!
      @all.each { |meth|
        send :define_method, meth, proc { |val = nil|
  		    return instance_variable_set %Q!@#{meth}!,val if val
            instance_variable_get %Q!@#{meth}!
		}
      }
	  end
  end
end