require 'yaml'
require 'programr/history'

module ProgramR
class Environment
  @@readOnlyTags = nil
  @@history      = nil

  def initialize
    return self unless(@@readOnlyTags == nil)
    @@readOnlyTags = YAML::load(
                          File.open( 
                            File.dirname(__FILE__) + 
                              "/../../conf/readOnlyTags.yaml"))
    @@history      = History.new
    srand(1)
  end

  def get(aTag)
    send(aTag)
  end

  def set(aTag,aValue)
    @@history.updateTopic(aValue) if(aTag == 'topic')
    @@readOnlyTags[aTag] = aValue
  end

  def method_missing(methId)
    tag = methId.id2name
    return @@history.send(tag) if(tag =~ /that$/)
    return @@readOnlyTags[tag] if(@@readOnlyTags.key?(tag))
    ''
  end
  
  def test
    #should overwrite test ....
    return @@readOnlyTags[tag] if(@@readOnlyTags.key?(tag))
    ''
  end
  
  def star(anIndex)
    @@history.getStar(anIndex)
  end
  
  def thatstar(anIndex)
    @@history.getThatStar(anIndex)
  end
  
  def topicstar(anIndex)
    @@history.getTopicStar(anIndex)
  end
  
  def male
    @@readOnlyTags['gender'] = 'male'
    return 'male'
  end
  
  def female
    @@readOnlyTags['gender'] = 'female'
    return 'female'
  end
  
  def question
    @@readOnlyTags['question'][rand(@@readOnlyTags['question'].length-1)]
  end

  def getRandom(anArrayofChoices)
    anArrayofChoices[rand(anArrayofChoices.length-1)]
  end

  def getStimula(anIndex)
    @@history.getStimula(anIndex)
  end
end
end
