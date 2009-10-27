require 'tableau'

desc "Migrate the tables"
task :migrate do
  DB.create_table!(:pastes) do
    primary_key :id
    String :description
  end

  DB.create_table!(:versions) do
    primary_key :id
    Integer :paste_id, :null => false
    DateTime :created_at, :null => false
    String :ip_address, :null => false
    String :language, :null => false
    Text :text, :null => false
  end
end
