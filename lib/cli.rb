class Command
  attr_reader :description
  def initialize(description, b)
   @description, @b = description, b
  end
  def call(*arg); @b.call(*arg); true end
end

module MetaCommand
  COMMANDS = []
  def self.add(cmd, description, &b)
    COMMANDS << [cmd, Command.new(description, b)]
  end

  def self.call(cmd)
    cmd,arg = cmd.split(/\s/,2)
    return unless COMMANDS.assoc(cmd)
    return COMMANDS.assoc(cmd)[1].call(arg) if arg
    COMMANDS.assoc(cmd)[1].call if COMMANDS.assoc(cmd)
  end
 
  def self.descriptions
    COMMANDS.collect{|cmd| [cmd[0], cmd[1].description]}
  end

  def self.pretty_print
    descriptions.map{|d| d[0] + ' - ' +  d[1]}.join "\n"
  end
end # module MetaCommand
