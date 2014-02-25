#!/usr/bin/ruby

class ActiveQueueThread 
    attr_accessor :queue
    attr_reader   :thread
    def initialize 
        @queue = Queue.new
        @thread = Thread.new &method(:run)
    end

    def run 
        loop do
            begin
                message = @queue.pop
                dispatch message
                break if message[0] == 'die'
            rescue => details
                puts Thread.current.to_s + self.class.name
                puts Thread.current.to_s + details.to_s
                puts Thread.current.to_s + details.backtrace.to_s
            end
        end
    end

    def join
        @thread.join
    end

    def self.send receiver, message
        receiver.queue << message
    end
end

class DataStorageManager < ActiveQueueThread
    def dispatch message
        if message[0] == 'init'
            initial message[1..-1]
        elsif message[0] == 'send_wf_freq'
            process_words message[1..-1]
        else
            ActiveQueueThread.send @stop_word_manager, message
        end
    end

    def initial message
        path_to_file, @stop_word_manager = message [0,2]
        @all_words = File.read(path_to_file).gsub((/[\W_]+/), ' ').downcase.split 
    end

    def process_words message
        recipient = message[0]
        @all_words.each {|w| ActiveQueueThread.send @stop_word_manager, ['filter', w]}
        ActiveQueueThread.send @stop_word_manager, ['top25', recipient]
    end
end

class StopWordManager < ActiveQueueThread
    def dispatch message
        if message[0] == 'init'
            initial message[1..-1]
        elsif message[0] == 'filter'
            filter message[1..-1]
        else
            ActiveQueueThread.send @frequencies, message
        end
    end

    def initial message
        @frequencies = message[0]
        @stop_words = File.read('../stop_words.txt').downcase.split(',')
        @stop_words.concat ('a'..'z').to_a
    end

    def filter message
        word = message[0]
        ActiveQueueThread.send @frequencies, ['word', word] unless @stop_words.include? word
    end
end

class FrequencyManager < ActiveQueueThread
    def initialize
        super
        @freq = Hash.new(0)
    end

    def dispatch message
        if message[0] == 'word'
            increament message[1..-1]
        elsif message[0] == 'top25'
            send_top25 message[1..-1]
        end
    end

    def increament message
        word = message[0]
        @freq[word] +=1
    end

    def send_top25 message
        recipient = message[0]
        top25 = @freq.sort_by {|a| -a[1]}
        ActiveQueueThread.send recipient, ['top25', top25.first(25)]
    end
end

class Controller < ActiveQueueThread
    def dispatch message 
        if message[0] == 'run'
            run_controler message[1..-1]
        elsif message[0] == 'top25'
            display message[1..-1]
        end
    end

    def run_controler message
        @storage = message[0]
        ActiveQueueThread.send @storage, ['send_wf_freq', self]
    end

    def display message
        wf = message[0]
        wf.each { |w,f| puts "#{w} - #{f}" }
        ActiveQueueThread.send @storage, ['die']
        ActiveQueueThread.send self, ['die']
    end
end


frequencies = FrequencyManager.new

stop_words = StopWordManager.new
ActiveQueueThread.send stop_words,['init', frequencies]

storage = DataStorageManager.new
ActiveQueueThread.send storage, ['init', ARGV[0], stop_words]

controller = Controller.new
ActiveQueueThread.send controller, ['run', storage]

[ frequencies, stop_words, storage, controller ].each {|t| t.join }

