require 'sinatra'
require 'haml'

$stopword = File.read('./data/stop_words.txt').downcase.split ','
$freq = {}

get '/' do
    "<h1>WordFrequency</h1>\n" +
        "<p>Hello, please upload your file :" +
        "<a href='/upload'><button>click me</button></a>"
end

get '/upload' do
    code = '%form{:action=>"/upload",:method=>"post"   ,:enctype=>"multipart/form-data"}'+ "\n" +
      '  %input{:type=>"file",:name=>"file"}' + "\n" +
      '    %input{:type=>"submit",:value=>"Upload"}'
    haml code
end

post '/upload' do
    if params['file']== nil
        return "<p> file not valid , please <a href='/upload'> upload again </a> "
    end

    filename = params['file'][:filename]
    freq = params['file'][:tempfile].read.downcase.scan(/[a-z]{2,}/).each_with_object(Hash.new(0)) do |word, hash|
        hash[word] +=1 unless $stopword.include? word
    end
    $freq[filename] = freq.sort_by {|a| -a[1]}
    "<h1><a href='/freq/#{filename}/0'>show freq </a></h1>"
end

get '/freq/*/*' do |filename, offset|
    $offset = offset.to_i
    $filename = filename
    code = "<h3>freqs from <%=$offset %> to <%=$offset+25%> </h3>" + 
        "<table><tr><th>Word</th><th>Freq</th>" +
        "<% $freq[$filename][$offset..($offset+25)].each do |w,q| %> " +
        "<tr>" +
            "<td><%= w %></td>" +
            "<td><%= q %></td>" +
        "</tr>" +
        "<% end %>" + 
        "</table>"
        
    code += "<table><tr>"
    if $offset > 0
        code += "<td><a href='/freq/<%=$filename%>/<%= $offset-25 %>'> prev  </a></td>"
    end
    if $offset+25 < $freq[filename].length
        code += "<td><a href='/freq/<%=$filename%>/<%= $offset+25 %>'> next  </a></td>"
    end
    code += "</tr></table>"
    code += "<a href='/'>home </a>"
    erb code
end

