namespace :import do
  desc "Import regions, departments and communes from renaloc.xlsx"
  task renaloc: :environment do
    require "roo"

    class ImportRenaloc
      def initialize(file_path = nil)
        @file_path = file_path || Rails.root.join("lib", "assets", "RENALOC.xlsx")
      end

      def call
        puts "START"

        unless File.exist?(@file_path.to_s)
          puts "Error: File not found at #{@file_path}"
          return { error: "File not found" }
        end

        xlsx = Roo::Spreadsheet.open(@file_path.to_s)

        imported_count = { regions: 0, departments: 0, communes: 0 }

        ActiveRecord::Base.transaction do
          xlsx.each_row_streaming(offset: 1).each_with_index do |row, index|
            import_row(row, imported_count)

            puts "Row #{index + 1} processed..." if (index + 1) % 1000 == 0
          end
        end

        puts "Import successfully !"
        puts "Results:"
        puts "- #{imported_count[:regions]} regions imported"
        puts "- #{imported_count[:departments]} departments imported"
        puts "- #{imported_count[:communes]} communes imported"

        imported_count
      rescue => e
        puts "Import error: #{e.message}"
        puts e.backtrace.join("\n")
        raise
      end

      private

      def import_row(row, counters)
        region_name = safe_string_value(row[2])
        department_name = safe_string_value(row[4])
        commune_name = safe_string_value(row[6])

        return if region_name.blank? || department_name.blank? || commune_name.blank?

        region = Region.find_or_create_by!(name: region_name) do |r|
          counters[:regions] += 1
        end

        department = Department.find_or_create_by!(name: department_name, region: region) do |d|
          counters[:departments] += 1
        end

        commune = Commune.find_or_create_by!(name: commune_name, department: department) do |c|
          counters[:communes] += 1
        end
      end

      def safe_string_value(cell)
        cell&.cell_value.to_s.strip.presence || ""
      end
    end

    importr = ImportRenaloc.new
    importr.call
  end
end

