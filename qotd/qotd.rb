#!/usr/bin/env ruby

QOTD_ROOT = File.dirname(__FILE__)
lib_dir = File.join(QOTD_ROOT, 'lib')
$: << lib_dir

%w{rubygems quotes sinatra date json}.each{|l| require l}

configure do
  set :qlib, Quotes.new(File.join(QOTD_ROOT, 'quotes.yml'))
end

helpers do
  def qlib
    options.qlib
  end
  
  def linebreak(text)
    text.gsub(/\n/, '<br/>')
  end
  
  def quote_div(quote)
    haml :quote_div, :locals => {:quote => quote}, :layout => false
  end
  
  def send_json(object)
    if params[:fmt] == 'json'
      content_type 'application/json'
      return object.to_json
    end
    return false
  end
end

template :quote_div do
  %q{
%div.quote
  %p
    = linebreak(quote[:text])
    %a{:href => "/quote/#{quote[:id]}"} #
  %p.attribution== &mdash;#{quote[:by]}
  }
end

get '/' do
  @quote = qlib.random(Date.today.jd)
  send_json(@quote) || haml(:index)
end

get '/quote/:id' do
  @quote = qlib[params[:id].to_i]
  send_json(@quote) || haml(:index)
end

get '/search/:key/:query' do
  re = Regexp.new(Regexp.escape(params[:query].downcase), Regexp::IGNORECASE)
  @quotes = qlib.search(re, params[:key].to_sym)
  send_json(@quotes) || haml(:search)
end

get '/stylesheet.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :stylesheet
end