require 'rubygems'
require 'sinatra'
require 'sequel'
require 'erb'
require 'albino'
require 'time_ago'

DB = Sequel.mysql 'tableau', :user => 'tableau', :password => 'tableau', :host => 'localhost'

class Paste < Sequel::Model
  plugin :validation_helpers
  one_to_many :versions
  self.raise_on_typecast_failure = false
end

class Version < Sequel::Model
  many_to_one :paste
  one_to_many :comments
  plugin :validation_helpers
  self.raise_on_typecast_failure = false

  set_dataset dataset.reverse_order(:created_at)

  def validate
    validates_presence(:text, :message => "can't be empty")
    validates_presence(:paste_id, :message => "can't be empty")
    validates_presence(:paster, :message => "can't be empty")
  end
end

class Comment < Sequel::Model
  many_to_one :version
  plugin :validation_helpers
  self.raise_on_typecast_failure = false

  set_dataset dataset.reverse_order(:created_at)
  def validate
    validates_presence(:text, :message => "can't be empty")
    validates_presence(:version_id, :message => "can't be empty")
    validates_presence(:paster, :message => "can't be empty")
  end
end

class String
  def blank?
    empty?
  end
end

class Object
  def blank?
    nil?
  end
end

get '/' do
  erb :index
end

get '/:id' do
  @paste = Paste[params[:id]]
  @version = @paste.versions.first
  erb :view
end

post '/:paste_id/comment/:version_id' do
  @comment = Comment.new(params[:comment].merge(:paster => request.ip, :version_id => params[:version_id]))
  if @comment.valid?
    @comment.save
  end
  redirect "/#{params[:paste_id]}/#{params[:version_id]}"
end

get '/edit/:version_id' do
  @version = Version[params[:version_id]]
  erb :edit
end

post '/edit/:paste_id' do
  @paste = Paste[:id => params[:paste_id]]
  @version = Version.new(params[:version].merge(:paster => request.ip, :paste_id => @paste.id))
  if @paste.valid? && @version.valid?
    @version.save
  end
  redirect "/#{@paste.id}/#{@version.id}"
end

get '/:paste_id/:version_id' do
  @paste = Paste[params[:paste_id]]
  @version = Version[params[:version_id]]
  erb :view
end

post '/paste' do
  @paste = Paste.new(params[:paste])
  if @paste.valid?
    @paste.save
  end
  @version = Version.new(params[:version].merge(:paster => request.ip, :paste_id => @paste.id))
  if @version.valid?
    @version.save
  end
  redirect "/#{@paste.id}"
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html

  def highlight(text, type=:ruby)
   Albino.new(text, type).colorize
  end
end
