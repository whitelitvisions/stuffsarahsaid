require 'sinatra'

helpers do
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['newquote', '']
  end
end

get '/' do
  chosen_line = nil
  chosen_line_array = nil
  author = nil
  quote = nil
  File.foreach("quotes").each_with_index do |line, number|
    chosen_line = line if rand < 1.0/(number+1)
  end
  chosen_line_array = chosen_line.split(",")
  author = chosen_line_array[0]
  quote = chosen_line_array[1]
  #rand(number of jpgs to rotate in background img folder)
  picnum = 1 + rand(5)
  erb :home, :locals => {:chosen_line_array => chosen_line_array, :picnum => picnum}
end

get '/newquote' do
  protected!
  erb :newquote_form
end

get '/submitted' do
  "Thank you for submitting a quote!"
end

post '/newquote' do
  protected!
  name = params[:name] || "Anonymous"
  quote = params[:quote]
  File.open('quotes', 'a') { |file| file.puts(name + "," + quote) }
  redirect '/submitted'
end
