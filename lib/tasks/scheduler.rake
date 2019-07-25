desc "===========Force logout all doctor==================="
task :force_logout_doctor => :environment do
  puts "===========Force logout all doctor==================="
  Doctor.all.each do |doctor|
    doctor.update_columns(available: false, auth_token: nil)
  end
  puts "=====================DONE============================"
end