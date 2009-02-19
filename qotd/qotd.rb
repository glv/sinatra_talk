#!/usr/bin/env ruby

QOTD_ROOT = File.dirname(__FILE__)
lib_dir = File.join(QOTD_ROOT, 'lib')
$: << lib_dir

%w{rubygems quotes sinatra builder date}.each{|l| require l}

configure do
  set :qlib, Quotes.load(File.join(QOTD_ROOT, 'quotes.yml'))
end

helpers do
  def qlib
    options.qlib
  end
  
  def quote_div(quote)
    haml :quote_div, :locals => {:quote => quote}
  end
end

get '/' do
  # @quote = qlib.random(Date.today.jd)
  @quote = qlib.random
  haml :index
end

get '/quote/:id' do
  @quote = qlib[params[:id].to_i]
  haml :index
end

get '/search/:key/:query' do
  re = Regexp.new(Regexp.escape(params[:query].downcase), Regexp::IGNORECASE)
  @quotes = qlib.search(re, params[:key].to_sym)
  haml :search
end

# requires and get '/' (with load in get)
# index.haml
# move load to configure
# add qlib helper
# get '/quote/:id'
# get '/search/:key/:query'
# search.haml
# helper or partial to generate the quote HTML wherever needed

# Layout
# CSS
# JSON output
# Maybe better handling of multiline quotes

# Quotes to feature:
#   1 absurdum, by Mike Jones
#  22 still more complicated, by Poul Anderson
#  24 screaming passengers, by Sverre Slotte
#  28 ironist, Donald Fagen
#  43 DestroyCity, Nathaniel Borenstein
#  51 witty saying, Voltaire
#  70 mustaches, Anita Wise
#  75 feminists, Douglas Hofstadter
#  93 doubt everything, Alfred Korzybski
#  95 web browser, Neal Stephenson
# 117 perfectionists, Donald Fagen
# 134 bonny book, Shaw

# Multiple searches
# by Donald Fagen
# 'stein' will turn up DestroyCity, along with others
# try searching for text=wise; no results.  Then try wis, for wisdom.  Also gets 70 and 100.  Win!
# text simpl (this one illustrates case-sensitivity)
# by Poul Anderson
# by Shaw

# Good multilines
# Ring the bell, Leonard Cohen
# Constraints, James Falen

# Good ids:
# 100, crappy old oses