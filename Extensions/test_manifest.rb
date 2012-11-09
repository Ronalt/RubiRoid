require "./manifest"
include Opera

h1,h2 = {name: "opera:speed_dial", required: false, speed_dial: "http://error.ru"},{name: "opera:share-cookies", required: true}

begin
x = Manifest::new

x.config do
name "ITest"
author "I"
description "I tested my framework"
author_email "erlang@gmail.com"
author_href "www.ekscalibur.net"
icon "non"
widget_id author_href

accesses origin: "http://yandex.ru", subdomains: true
features [h1,h2] 
preferences name: "Smbody", value: "Smthing"

langs :fr,:sui,:de
author_lang [:ru,:de]

author_ru "Ya"
author_fr "Je"
author_de "Ich"
description_fr "Returi de juli o derit tu Berie."
description_de  description_fr
end

x.create
puts "Completed!"
puts `pause`
rescue => e
puts e.message
puts e.backtrace
puts `pause`
end