# Add the lib directory to the load path.
$:.unshift(File.dirname(__FILE__) + '/lib')

# Dependencies.
require 'rubygems'
require 'sinatra'
require 'sequel'
require 'erb'
require 'albino'

DB = Sequel.connect("sqlite://tableau.db")

class Paste < Sequel::Model
  plugin :validation_helpers
  one_to_many :versions
  self.raise_on_typecast_failure = false

  set_dataset dataset.reverse_order(:id)

  def text
    if versions.empty?
      ""
    else
      versions.first.text
    end
  end

  def excerpt
    text.split("\n")[0..4].join("\n")
  end

  def language
    if versions.empty?
      "text"
    else
      versions.first.language
    end
  end

  def ip_address
    if versions.empty?
      ""
    else
      versions.first.ip_address
    end
  end
end

class Version < Sequel::Model
  many_to_one :paste
  plugin :validation_helpers
  self.raise_on_typecast_failure = false

  set_dataset dataset.reverse_order(:created_at)

  def description
    paste.description
  end

  def validate
    validates_presence(:text, :message => "can't be empty")
    validates_presence(:language, :message => "must be chosen")
    validates_presence(:paste_id, :message => "can't be empty")
    validates_presence(:ip_address, :message => "can't be empty")
  end
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html

  def highlight(text, language=:text)
    Albino.new(text, language)
  end

  def select_language(language="text")
    languages = {
      "as" => "ActionScript",
      "csharp" => "C#",
      "c" => "C/C++",
      "css" => "CSS",
      "diff" => "Diff",
      "html+erb" => "HTML (ERB / Rails)",
      "html" => "HTML / XML",
      "java" => "Java",
      "js" => "Javascript",
      "objc" => "Objective C/C++",
      "pascal" => "Pascal",
      "pl" => "Perl",
      "php" => "PHP",
      "text" => "Plain text",
      "py" => "Python",
      "ruby" => "Ruby",
      "sh" => "Shell Script (Bash)",
      "sql" => "SQL",
      "yaml" => "YAML"
    }

    select = '<select name="version[language]">'

    languages.each do |code, human_name|
      if code == language
        select << "<option value=\"#{code}\" selected=\"selected=\">#{human_name}</option>"
      else
        select << "<option value=\"#{code}\">#{human_name}</option>"
      end
    end

    select << "</select>"
  end
end

get '/' do
  @pastes = Paste
  erb :index
end

post '/' do
  @paste = Paste.new(params[:paste])
  @version = Version.new(params[:version])
  if @paste.save && @paste.add_version(@version)
    redirect "/#{@paste.id}"
  else
    erb :index
  end
end

get '/:paste_id' do
  @paste = Paste[params[:paste_id]]
  @version = @paste.versions.first
  erb :show
end

get '/:paste_id/edit' do
  @paste = Paste[params[:paste_id]]
  @version = @paste.versions.first
  erb :edit
end

put '/:paste_id' do
  @paste = Paste[params[:paste_id]]
  @version = Version.new(params[:version])
  if @paste.add_version(@version)
    redirect "/#{@paste.id}"
  end
end

get '/:paste_id/:version_id' do
  @paste = Paste[params[:paste_id]]
  if @version = @paste.versions_dataset[:id => params[:version_id]]
    erb :show
  else
    raise Sinatra::NotFound
  end
end
