# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

puts 'Roles'
Seeds::FillRoles.perform_for %w[super_admin admin user guest]

puts 'Default users'
Seeds::FillUsers.perform_for [
                               {email: 'unknown@cccdemo.cz', password: '2.*.+.-.', roles: %w[guest]},

                               {email: 'superadmin@cccdemo.cz', password: 'ccc*superadmin*676', roles: %w[user super_admin]},

                               {email: 'admin@cccdemo.cz', password: 'ccc*admin*654', roles: %w[user admin]},

                               {email: 'user@cccdemo.cz', password: 'ccc*user*321', roles: %w[user]}
                             ]

