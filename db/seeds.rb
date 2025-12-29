# Create default admin user
admin = User.find_or_initialize_by(email: "admin@gmail.com")
if admin.new_record?
  admin.assign_attributes(
    password: "password",
    password_confirmation: "password",
    profile: :admin,
    first_name: "admin_firstname",
    last_name: "admin_lastname",
    is_verified: true
  )
  admin.save!
  puts "✅ Admin créé : #{admin.email}"
else
  puts "ℹ️  Admin existe déjà : #{admin.email}"
end
