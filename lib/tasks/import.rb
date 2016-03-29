namespace :import do
  desc "Imports FitBit data from the FitBit API"
  task :fitbit => :environment do

    # csv_text = File.read('clist.csv')
    # csv = CSV.parse(csv_text, :headers=>false)
    # csv.each do |row|
    #   company = Company.create(
    #     :name => row[0]
    #   )
    # end
  end
end

# task :world => :import_companies do
#   puts "World"
# end
