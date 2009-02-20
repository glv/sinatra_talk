#!/usr/bin/env ruby

QOTD_ROOT = File.dirname(__FILE__)
lib_dir = File.join(QOTD_ROOT, 'lib')
$: << lib_dir

%w{rubygems quotes sinatra builder date json}.each{|l| require l}

configure do
  set :qlib, Quotes.load(File.join(QOTD_ROOT, 'quotes.yml'))
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


# requires and get '/' (with load in get)
# index.haml                                // today's and then random
# move load to configure
# add qlib helper
# get '/quote/:id'                          // 1, 100
# Layout                                    // 75
# CSS                                       // 22
# get '/search/:key/:query'
# search.haml                               // by/shaw, by/stein, text/wise, text/wis, text/simpl
# case-sensitivity in searches              // text/simpl text/tv
# helper or partial to generate the quote HTML wherever needed (as internal template) // text/scream
# JSON output
# Maybe better handling of multiline quotes // text/constraint
# End with                                  // by/vol

# Other things to mention:
# filters
# halting and passing
# more complicated route processing
# environments
# error handling
# Rack

# Quotes to feature:
#   1 absurdum, by Mike Jones                  // :id
#  22 still more complicated, by Poul Anderson // CSS
#  24 screaming passengers, by Sverre Slotte   // search/text/scream
#  28 ironist, Donald Fagen                    // search/text/tv
#  43 DestroyCity, Nathaniel Borenstein        // search/by/stein
#  51 witty saying, Voltaire                   // by/vol
#  70 mustaches, Anita Wise                    // text/wis
#  75 feminists, Douglas Hofstadter            // layout
#  93 doubt everything, Alfred Korzybski
#  95 web browser, Neal Stephenson
# 117 perfectionists, Donald Fagen
# 134 bonny book, Shaw                         // search/by/shaw

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
# 100, crappy old oses                        // :id