#!/usr/bin/ruby

class Event
    attr_reader :type, :value

    def initialize type, value
        @type = type
        @value = value
    end
end

class EventManager
    def initialize
        @subscriber = Hash.new([])
    end
    
    def subsribe event_type, handler
        @subscriber[event_type] += [handler]
    end

    def publish event
        @subscriber[event.type].each { |handler| handler.call event }
    end
end

class WordsStorage
    def initialize event_manager
        @event_manager = event_manager
        @event_manager.subsribe 'load', self.method(:load)
        @event_manager.subsribe 'start', self.method(:produce_word)
    end
    
    def load event
        @data = File.read(event.value).downcase.split(/[\W_]+/).reject { |w| w.length < 2 } 
    end

    def produce_word event
        @data.each { |w| @event_manager.publish( Event.new('word',w)) }
        @event_manager.publish( Event.new('eof', nil))
    end
end

class StopWordFilter
    def initialize event_manager
        @event_manager = event_manager
        @event_manager.subsribe 'load', self.method(:load)
        @event_manager.subsribe 'word', self.method(:is_stop_word?)
    end

    def load event
        @stopwords = File.read('../stop_words.txt').downcase.split(',')       
    end

    def is_stop_word? event
        if not @stopwords.include? event.value
            @event_manager.publish( Event.new('valid_word', event.value)) 
        end
    end
end

class WordFrequencyCounter
    def initialize event_manager
        @event_manager = event_manager
        @event_manager.subsribe 'valid_word', self.method(:increment)
        @event_manager.subsribe 'print', self.method(:print)
        @counter = Hash.new(0)
    end

    def increment event
        @counter[event.value] +=1
    end

    def print event
        @counter.sort_by {|a| -a[1]}.first(25).each {|k,v| puts "#{k} - #{v}"}
    end
end

class Application
    def initialize event_manager
        @event_manager = event_manager
        @event_manager.subsribe 'run', self.method(:run)
        @event_manager.subsribe 'eof', self.method(:on_eof)
    end

    def run event
        @event_manager.publish Event.new('load', event.value)
        @event_manager.publish Event.new('start', nil )
    end

    def on_eof event
        @event_manager.publish Event.new('print', nil)
    end
end

#################################################################################
# Here is the new class to deal with the word with 'z'
class WordsWithZ
    def initialize event_manager
        @event_manager = event_manager
        @event_manager.subsribe 'valid_word', self.method(:with_z?)
        @event_manager.subsribe 'print', self.method(:print)
        @count = 0
    end

    def with_z? event
        @count += (event.value.include? 'z') ? 1 : 0
    end

    def print event
        puts "The number of non-stop words with the letter z : #{@count}"
    end
end

em = EventManager.new

WordsStorage.new em
StopWordFilter.new em
WordFrequencyCounter.new em
Application.new em
WordsWithZ.new em

em.publish Event.new('run', ARGV[0])
