# frozen_string_literal: true
module Seeds
  class FillRoles
    def self.perform_for(roles)
      roles.each do |role|
        puts "role: #{role}" unless Role.find_or_create_by!(name: role).previous_changes.empty?
      end
    end
  end
end
