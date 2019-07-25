ActiveAdmin.register Doctor do
  menu parent: 'Doctors', priority: 0
  config.batch_actions = false
  #permit_params :email, :password, :password_confirmation

  index :download_links => false do
    selectable_column
    # id_column
    column :name
    column :email
    column :gender
    column :agency, :sortable => 'agencies.name' do |d|
      d.agency.present? ? ( link_to d.agency.name, admin_agency_path(d.agency.id) ) : 'None'
    end
    # column 'Mobile Phone', :phone_number
    # column 'Landline Phone', :phone_landline
    column :company_name
    column 'Working Zones', :doctor_zone_list
    column :address
    column :latitude
    column :longitude
    column :default_start_location
    column :status
    column :reason do |d|
      raw(truncate(d.reason, omision: "...", length: 8))
    end
    column :available
    column :auth_token
    column :answer_about_us
    column :created_at
    column :updated_at
    # column :avatar do |d|
    #   image_tag d.avatar.url, width: "50px", height: "50px"
    # end
    # column 'GMC Certificate', :gmc_cert do |d|
    #   link_to d.get_document_link('gmc_cert'), d.gmc_cert.url unless d.gmc_cert.url.blank?
    # end
    # column 'DBS Certificate', :dbs_cert do |d|
    #   link_to d.get_document_link('dbs_cert'), d.dbs_cert.url unless d.dbs_cert.url.blank?
    # end
    # column 'MDU/MPS Certificate', :mdu_mps_cert do |d|
    #   link_to d.get_document_link('mdu_mps_cert'), d.mdu_mps_cert.url unless d.mdu_mps_cert.url.blank?
    # end
    # column 'Passport Scan', :passport do |d|
    #   image_tag d.passport.url, width: "50px", height: "50px"
    # end
    # column 'Appraisal Summary', :last_appraisal_summary do |d|
    #   link_to d.get_document_link('last_appraisal_summary'), d.last_appraisal_summary.url unless d.last_appraisal_summary.url.blank?
    # end
    # column 'Reference From Another GP', :reference_gp do |d|
    #   link_to d.get_document_link('reference_gp'), d.reference_gp.url unless d.reference_gp.url.blank?
    # end
    # column 'Hepatitis B Status', :hepatitis_b_status do |d|
    #   link_to d.get_document_link('hepatitis_b_status'), d.hepatitis_b_status.url unless d.hepatitis_b_status.url.blank?
    # end
    # column 'Child Protection Certificate', :child_protection_cert do |d|
    #   link_to d.get_document_link('child_protection_cert'), d.child_protection_cert.url unless d.child_protection_cert.url.blank?
    # end
    # column 'Adult Safeguarding Certificate', :adult_safeguarding_cert do |d|
    #   link_to d.get_document_link('adult_safeguarding_cert'), d.adult_safeguarding_cert.url unless d.adult_safeguarding_cert.url.blank?
    # end
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :email
      row :gender
      row :address
      row :latitude
      row :longitude
      row :auth_token
      row :agency do |d|
        d.agency.present? ? d.agency : 'None'
      end
      row :first_name
      row :last_name
      row :role
      row "Hold Status" do |d|
        d.is_hold
      end
      row "Transportation Method" do |d|
        d.get_transportation_method
      end
      row :company_name
      row 'Mobile Phone' do |d|
        d.phone_number
      end
      row 'Landline Phone' do |d|
        d.phone_landline
      end
      row :avatar do |d|
        image_tag d.avatar.url, width: "50px", height: "50px"
      end
      row 'GMC Certificate' do |d|
        link_to d.get_document_link('gmc_cert'), d.gmc_cert.url unless d.gmc_cert.url.blank?
      end
      row 'GMC certificate expiration date' do |d|
        d.gmc_cert_exp
      end
      row 'DBS Certificate' do |d|
        link_to d.get_document_link('dbs_cert'), d.dbs_cert.url unless d.dbs_cert.url.blank?
      end
      row 'DBS Certificate expiration date' do |d|
        d.dbs_cert_exp
      end
      row 'MDU/MPS Certificate' do |d|
        link_to d.get_document_link('mdu_mps_cert'), d.mdu_mps_cert.url unless d.mdu_mps_cert.url.blank?
      end
      row 'MDU/MPS Certificate expiration date' do |d|
        d.mdu_mps_cert_exp
      end
      row 'Passport Scan' do |d|
        image_tag d.passport.url, width: "50px", height: "50px"
      end
      row 'Appraisal Summary' do |d|
        link_to d.get_document_link('last_appraisal_summary'), d.last_appraisal_summary.url unless d.last_appraisal_summary.url.blank?
      end
      row 'Appraisal Summary expiration date' do |d|
        d.last_appraisal_summary_exp
      end
      row 'Reference from another GP' do |d|
        link_to d.get_document_link('reference_gp'), d.reference_gp.url unless d.reference_gp.url.blank?
      end
      row 'Hepatitis B Status' do |d|
        link_to d.get_document_link('hepatitis_b_status'), d.hepatitis_b_status.url unless d.hepatitis_b_status.url.blank?
      end
      row 'Hepatitis B Status expiration date' do |d|
        d.hepatitis_b_status_exp
      end
      row 'Child Protection Certificate' do |d|
        link_to d.get_document_link('child_protection_cert'), d.child_protection_cert.url unless d.child_protection_cert.url.blank?
      end
      row 'Child Protection Certificate expiration date' do |d|
        d.child_protection_cert_exp
      end
      row 'Adult Safeguarding Certificate' do |d|
        link_to d.get_document_link('adult_safeguarding_cert'), d.adult_safeguarding_cert.url unless d.adult_safeguarding_cert.url.blank?
      end
      row 'Adult Safeguarding Certificate expiration date' do |d|
        d.adult_safeguarding_cert_exp
      end
      row 'Working Zones' do |d|
        d.doctor_zone_list
      end
      row :default_start_location
      row :status
      row 'Reason' do |d|
        raw(truncate(d.reason, omision: "...", length: 20)) if d.rejected?
      end
      row :available
      row :device_token
      row :platform
      row :created_at
      row :updated_at
    end
  end

  filter :name
  filter :email
  filter :phone_number
  filter :phone_landline


  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "Admin Details" do
      f.input :name
      f.input :email
      if f.object.new_record?
        f.input :password
        f.input :password_confirmation
      end
      f.input :first_name
      f.input :last_name
      f.input :gender, as: :select, collection: [["Female", "Female"], ["Male", "Male"]], include_blank: "Select gender"
      f.input :company_name
      f.input :phone_number, label: 'Mobile phone'
      f.input :phone_landline, label: 'Landline phone'
      f.input :address
      f.input :latitude
      f.input :longitude
      f.input :agency_id, as: :select, :collection => Agency.approved.order("name").unshift(Agency.new(id: nil, name: "None")).map{|a| [a.name, a.id]}, :include_blank => false
      f.input :avatar, :hint => "The format file is jpg/jpeg/gif/png"#, :image_preview => true
      f.input :gmc_cert, label: "GMC certificate", :hint => "The format file is pdf"
      f.input :gmc_cert_exp, label: "GMC certificate expiration date", as: :date_picker
      f.input :dbs_cert, label: "DBS certificate", :hint => "The format file is pdf"
      f.input :dbs_cert_exp, label: "DBS certificate expiration date",  as: :date_picker
      f.input :mdu_mps_cert, label: "MDU/MPS certificate", :hint => "The format file is pdf"
      f.input :mdu_mps_cert_exp, label: "MDU/MPS certificate expiration date",  as: :date_picker
      f.input :passport, label: "Passport scan", :hint => "The format file is jpg/jpeg/gif/png"#, :image_preview => true
      f.input :last_appraisal_summary, label: "Appraisal summary", :hint => "The format file is pdf"
      f.input :last_appraisal_summary_exp, label: "Appraisal summary expiration date",  as: :date_picker
      f.input :reference_gp, label: "Reference from another GP", :hint => "The format file is pdf"
      f.input :hepatitis_b_status, label: "Hepatitis B status", :hint => "The format file is pdf"
      f.input :hepatitis_b_status_exp, label: "Hepatitis B status expiration date",  as: :date_picker
      f.input :child_protection_cert, label: "Child protection certificate", :hint => "The format file is pdf"
      f.input :child_protection_cert_exp, label: "Child protection certificate expiration date",  as: :date_picker
      f.input :adult_safeguarding_cert, label: "Adult safeguarding certificate", :hint => "The format file is pdf"
      f.input :adult_safeguarding_cert_exp, label: "Adult safeguarding certificate expiration date",  as: :date_picker
      f.inputs do
        f.has_many :doctor_zones, allow_destroy: true do |z|
          z.input :zone_id, :collection => Zone.order('name'), :label_method => :name, :value_method => :name, :include_blank => false, input_html: {class: "zone-select2"}, as: :select
        end
      end

      f.input :default_start_location, :collection => Zone.order('name').map(&:name), :include_blank => false
      f.input :status, as: :radio, :label => "Status", :collection => Agency.modify_status.keys.to_a
      f.input :reason, as: :text
      f.input :available
      f.input :description, label: "About", as: :text
    end
    f.actions
  end

  controller do
    def update
      # valid = true
      # hash = params[:doctor][:doctor_zones_attributes]
      # (0...hash.count).each do |x|
      #   if hash["#{x}"]["zone_id"].nil?
      #     valid = false
      #   end
      # end
      # # resource.errors[:base] << "OK"
      # if valid
      #   update! do |format|
      #     format.html { redirect_to admin_doctors_path } if resource.valid?
      #   end
      # else
      #   resource.errors[:base] << "Doctor zone can't be blank. You can delete it if you want."
      #   render action: :edit
      # end
      puts "params[:doctor] = #{params[:doctor].inspect}"
      if params[:doctor][:gender].blank?
        resource.errors.add(:gender, "can't be blank")
        render action: :edit
      else
        update! do |format|
          format.html { redirect_to admin_doctors_path } if resource.valid?
        end
      end
    end

    def create
      create! do |format|
        format.html { redirect_to admin_doctors_path } if resource.valid?
      end
    end

    def scoped_collection
      super.includes(:agency)
    end

    def permitted_params
      if params[:action].to_s == "new" || params[:action].to_s == "create"
        params.permit doctor: [:name, :email, :password, :password_confirmation, :company_name, :description, :first_name, :last_name, :gender, :role, :phone_number, :phone_landline, :avatar, :agency_id,
                               :gmc_cert, :dbs_cert, :mdu_mps_cert, :passport, :default_start_location, :last_appraisal_summary,
                               :reference_gp, :hepatitis_b_status, :child_protection_cert, :adult_safeguarding_cert, :status,
                               :gmc_cert_exp, :dbs_cert_exp, :mdu_mps_cert_exp, :last_appraisal_summary_exp, :hepatitis_b_status_exp,
                               :child_protection_cert_exp, :adult_safeguarding_cert_exp, :available, :reason, :address,
                               doctor_zones_attributes: [:zone_id, :doctor_id, :eta, :_destroy, :id]]
      else
        params.permit doctor: [:name, :email, :phone_number, :phone_landline, :company_name, :description, :first_name, :last_name, :gender, :role, :avatar, 
                               :gmc_cert, :dbs_cert, :mdu_mps_cert, :agency_id, :latitude, :longitude,
                               :passport, :default_start_location, :last_appraisal_summary, :reference_gp, :hepatitis_b_status, :reason,
                               :child_protection_cert, :adult_safeguarding_cert, :status, :gmc_cert_exp, :dbs_cert_exp, :mdu_mps_cert_exp,
                               :last_appraisal_summary_exp, :hepatitis_b_status_exp, :child_protection_cert_exp, :adult_safeguarding_cert_exp, :address,
                               :available, doctor_zones_attributes: [:zone_id, :doctor_id, :eta, :_destroy, :id]]
      end
    end
  end


end
