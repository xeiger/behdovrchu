require 'csv'

namespace :entrant do

  desc "export billing log to CSV for italian billings"
  task :import => :environment do

    Rails.logger.info("[IMPORT_POLICIES] START")

    file_path = Rails.root + 'doc/entrants.csv'
    row_no = 0
    CSV.parse(File.open(file_path, 'rb'), headers: false, col_sep: ';') do |row|

      row_no += 1
      begin

        e = Entrant.new
        e.first_name = row[0]
        e.surname = row[1]
        e.club = row[2] unless row[2].blank?
        e.address = row[3] unless row[3].blank?
        e.email = row[4]
        e.variable_symbol = row[5]
        e.year = row[6]
        e.male = row[7]
        e.climber = row[8]

        e.save!

        Rails.logger.info("[IMPORT_ENTRANTS] #{row_no} OK entrant: #{e.id}")
      rescue => exc
        Rails.logger.info("[IMPORT_ENTRANTS] #{row_no} ERR entrant: #{e.id}, exc: {exc.message")
      end

    end

    Rails.logger.info("[IMPORT_POLICIES] KONEC")
  end
end
