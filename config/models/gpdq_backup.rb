# encoding: utf-8

##
# Backup Generated: gpdq_backup
# Once configured, you can run the backup with the following command:
#
# $ backup perform -t gpdq_backup [-c <path_to_configuration_file>]
#
# For more information about Backup's components, see the documentation at:
# http://backup.github.io/backup
#

require 'yaml'

database_yml = File.expand_path('../../../config/database.yml',  __FILE__)
database_config = YAML.load_file(database_yml)
s3_yml = File.expand_path('../../../config/s3.yml',  __FILE__)
s3_config = YAML.load_file(s3_yml)

Model.new(:gpdq_backup, 'Description for gpdq_backup') do
  ##
  # Archive [Archive]
  #
  # Adding a file or directory (including sub-directories):
  #   archive.add "/path/to/a/file.rb"
  #   archive.add "/path/to/a/directory/"
  #
  # Excluding a file or directory (including sub-directories):
  #   archive.exclude "/path/to/an/excluded_file.rb"
  #   archive.exclude "/path/to/an/excluded_directory
  #
  # By default, relative paths will be relative to the directory
  # where `backup perform` is executed, and they will be expanded
  # to the root of the filesystem when added to the archive.
  #
  # If a `root` path is set, relative paths will be relative to the
  # given `root` path and will not be expanded when added to the archive.
  #
  #   archive.root '/path/to/archive/root'
  
  # archive :my_archive do |archive|
  #   # Run the `tar` command using `sudo`
  #   # archive.use_sudo
  #   archive.add "/path/to/a/file.rb"
  #   archive.add "/path/to/a/folder/"
  #   archive.exclude "/path/to/a/excluded_file.rb"
  #   archive.exclude "/path/to/a/excluded_folder"
  # end
  
  ##
  # PostgreSQL [Database]
  #
  database PostgreSQL do |db|
    # To dump all databases, set `db.name = :all` (or leave blank)
    db.name               = database_config["production"]["database"]
    db.username           = database_config["production"]["username"]
    db.password           = database_config["production"]["password"]
    db.host               = database_config["production"]["host"]
    db.port               = database_config["production"]["port"]
    # db.socket             = "/tmp/pg.sock"
    # When dumping all databases, `skip_tables` and `only_tables` are ignored.
    # db.skip_tables        = ["skip", "these", "tables"]
    # db.only_tables        = ["only", "these", "tables"]
    db.additional_options = ["-xc", "-E=utf8"]
  end

  ##
  # Amazon Simple Storage Service [Storage]
  #
  store_with S3 do |s3|
    # AWS Credentials
    s3.access_key_id     = s3_config["production"]["access_key"]
    s3.secret_access_key = s3_config["production"]["secret_access_key"]
    # Or, to use a IAM Profile:
    # s3.use_iam_profile = true

    s3.region            = s3_config["production"]["region"]
    s3.bucket            = s3_config["production"]["backup_database_bucket"]
    # s3.path              = "path/to/backups"
    s3.keep              = s3_config["production"]["database_backup_quantity"]
  end
  
  ##
  # Amazon Simple Storage Service [Storage]
  #
  # store_with S3 do |s3|
  #   # AWS Credentials
  #   s3.access_key_id     = "my_access_key_id"
  #   s3.secret_access_key = "my_secret_access_key"
  #   # Or, to use a IAM Profile:
  #   # s3.use_iam_profile = true

  #   s3.region            = "us-east-1"
  #   s3.bucket            = "bucket-name"
  #   s3.path              = "path/to/backups"
  #   s3.keep              = 5
  #   # s3.keep              = Time.now - 2592000 # Remove all backups older than 1 month.
  # end

  ##
  # Gzip [Compressor]
  #
  compress_with Gzip

  ##
  # Mail [Notifier]
  #
  # The default delivery method for Mail Notifiers is 'SMTP'.
  # See the documentation for other delivery options.
  #
  # notify_by Mail do |mail|
  #   mail.on_success           = true
  #   mail.on_warning           = true
  #   mail.on_failure           = true

  #   mail.from                 = "sender@email.com"
  #   mail.to                   = "receiver@email.com"
  #   mail.cc                   = "cc@email.com"
  #   mail.bcc                  = "bcc@email.com"
  #   mail.reply_to             = "reply_to@email.com"
  #   mail.address              = "smtp.gmail.com"
  #   mail.port                 = 587
  #   mail.domain               = "your.host.name"
  #   mail.user_name            = "sender@email.com"
  #   mail.password             = "my_password"
  #   mail.authentication       = "plain"
  #   mail.encryption           = :starttls
  # end

end
