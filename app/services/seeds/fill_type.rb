# frozen_string_literal: true
module Seeds
  class FillType
    def self.perform_for(class_name:, codes:)
      puts class_name
      class_name = class_name.constantize if class_name.is_a? String
      codes.each do |code|
        puts "code:  #{code}" unless class_name.find_or_create_by!(code: code).previous_changes.empty?
      end
    end
  end
end
