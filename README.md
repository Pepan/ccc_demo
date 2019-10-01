# README

Playground app for checking possibilities of cancancan with rolify

It is Rails 6.0 with webpacked assets in app/javascript folder!

_I prepared it to be restricted by default. Important areas are protected by ```before_action :check_admin_access``` in ApplicationController._
_CRUD oprations are protected by ```load_and_authorize_resource only: %i[show edit update destroy]``` also in ApplicationController._

Playground toys:
* log-in
* log-out
* users with different roles
* areas accessible by role (limited by ```can? :do_something, on_something``` in views and ```authorize! :to_do_something, on_something``` in controllers)

Notes:
* user roles ```guest, user, admin, superadmin```
* anyone not logged is user too! Just having role guest.
* accessibility is defined in ```app/models/ability.rb```
* users are defined in ```db/seeds.rb```
* ```schema.rb``` included! :)
* _there is no design at all_
* sorry for cryptic user list. I was just lazy and copied user model as it was.
* I think running ```yarn install``` will be necessary alongside with other preparation commands

Areas:
* Homepage - accessible by anyone (it does not authorize anything by ```skip_before_action :check_admin_access, only: [:home, :something]```)
* something page - accessible by *user role*  - someone logged in
* users list page - accessible by admins - role with ```can :access, :admin``` set
* deleting users - accessible only by *super_admin*

