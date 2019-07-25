ActiveAdmin.register GpdqPhone do

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  menu priority: 1, parent: 'Contact Us'
  permit_params :department, :phone_number, :is_published

end
