# frozen_string_literal: true

module Seeds
  class FillUsers
    def self.perform_for(users)
      users.each do |info|
        role_ids = Role.where(name: info.delete(:roles)).pluck(:id)
        user = User.create_with(
          info.merge(seeding: true,
                     email: info[:email],
                     role_ids: role_ids,
                     confirmed_at: Time.current)
        ).find_or_create_by login_digest: User.searchable_digest_from(info[:email], User::LOGIN_DIGEST_ID)

        raise "user: #{info[:email]} errors: " + user.errors.full_messages.to_s if user.errors.any?

        puts "user: #{info[:email]}" if user.previous_changes.any?
      end
    end
  end
end
