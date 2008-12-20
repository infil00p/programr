require 'programr/facade'
require 'rubygems'
require 'festivaltts4r'

if ARGV.empty?
  puts 'Please pass a list of AIMLs and/or directories as parameters'
  puts 'Usage: programR {aimlfile|dir}[{aimlfile|dir}]...'
  exit
end

robot = ProgramR::Facade.new
robot.learn(ARGV) 

# Pretty output
require 'cli'
MetaCommand::add('\p','dump master graph'){puts robot}
MetaCommand::add('\q','exit programR'){exit}
MetaCommand::add('\l','load cache [filename] replacing master graph'){|*arg| 
  robot.loading(*arg)
}
MetaCommand::add('\m','load cache [filename] merging into master graph'){|*arg|
  robot.merging(*arg)
}
MetaCommand::add('\d','dump cache [filename]'){|*arg| robot.dumping(*arg)}
#MetaCommand::add('\h','help'){ puts MetaCommand.pretty_print }

puts '-'*40
puts '  programR version 0.0.1'
puts '  copyleft 2006 dottorsi group'
puts '-'*40
puts MetaCommand.pretty_print
puts ''

while true
  print '>> '
  s = STDIN.gets.chomp
  next if MetaCommand.call(s)
  reaction = robot.get_reaction(s)
  reaction.to_speech
  STDOUT.puts '<< '+ reaction
end
