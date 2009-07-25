# Artice node bodies of OpenKH 0.5 are in YAML, we use Ruby to convert YAML
# data to plain text so that the data can be easily migrated by Erlang.

require 'yaml'

Files = Dir.glob('./*.yaml')

Files.each do |f|
  a = YAML::load(File.read(f))
  abstract = a[0]
  body     = a[1]
  File.open(f + '.abstract.txt', 'w') { |f2| f2.write(abstract) }
  File.open(f + '.body.txt',     'w') { |f2| f2.write(body) }
end
