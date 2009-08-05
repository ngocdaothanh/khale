# Artice and poll node bodies of OpenKH 0.5 are in YAML, we use Ruby to convert
# YAML data to plain text so that the data can be easily migrated by Erlang.

require 'yaml'

def article_yml_to_txt(fn, yml)
  abstract = yml[0]
  body     = yml[1]
  File.open(fn + '.abstract.txt', 'w') { |f2| f2.write(abstract) }
  File.open(fn + '.body.txt',     'w') { |f2| f2.write(body) }
end

def poll_yml_to_txt(fn, yml)
  choices = yml[0]
  votes   = yml[1]
  voters  = yml[2] - [0]

  s = "{#{choices.inspect}, #{votes.inspect}, #{voters.inspect}}."
  File.open(fn + '.txt', 'w') { |f2| f2.write(s) }
end

Files = Dir.glob('./*.yml')
Files.each do |fn|
  yml = YAML::load(File.read(fn))
#  article_yml_to_txt(fn, yaml)
  poll_yml_to_txt(fn, yml)
end
