namespace :entrant do

  desc "Archive all current (non-archived) entrants - run before opening registration for a new year"
  task :archive => :environment do
    count = Entrant.where(archived: false).update_all(archived: true)
    puts "Archived #{count} entrants"
  end

end
