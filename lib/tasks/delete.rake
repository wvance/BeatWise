namespace :delete do
  desc "Delete all HeartData"
  task :heartData => :environment do
    Content.where(:provider => "fitbit").destroy_all
  end
end
