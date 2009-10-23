require 'tableau'

desc "Migrate the Pastie table"
task :migrate do
  DB.create_table!(:pastes) do
    primary_key :id 
    String :description
  end
end

desc "Migrate the Versions table"
task :migrate do
  DB.create_table!(:versions) do
    primary_key :id
    Integer :paste_id, :null => false
    DateTime :created_at, :null => false
    String :highlight, :default => 'text'
    String :paster, :null => false
    Text :text, :null => false
  end
end

desc "Migrate the Comments table"
task :migrate do
  DB.create_table!(:comments) do
  primary_key :id
  Integer :version_id, :null => false
  DateTime :created_at, :null => false  
  String :paster, :null => false
  String :text
  end
end
