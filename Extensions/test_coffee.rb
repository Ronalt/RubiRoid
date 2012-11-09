require "./coffee.rb"
include Opera
begin
c = JSiCO.new
c.filename "background.js"
c.language :coffee_script
c.compiler_path "http://jashkenas.github.com/coffee-script/extras/coffee-script.js"
c.compile "square = (x) -> x * x"
rescue => e
p e.message
p e.backtrace
end