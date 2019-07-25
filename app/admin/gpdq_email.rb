ActiveAdmin.register GpdqEmail do

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  menu priority: 0, parent: 'Contact Us'
  permit_params :department, :email, :is_published

end
