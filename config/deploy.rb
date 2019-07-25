# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'gpdq.co.uk'
set :repo_url, 'git@git.assembla.com:doctorapp.git'

# Default branch is :master
# set :branch, 'feature/deployment'
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/webapps/gpdq.co.uk'

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, ['config/database.yml',
                    'config/judopay.yml',
                    'config/paypal.yml',
                    'config/redis.yml',
                    'config/s3.yml',
                    'config/secrets.yml',
                    'config/textmarketer.yml',
                    'config/unicorn.rb'
]

set :bundle_binstubs, nil
# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5
set :rvm_ruby_version, '2.1.5@global'

set :rails_env, 'production'

set :unicorn_pid, ->{ "#{shared_path}/tmp/pids/unicorn.pid" }

namespace :rails do
  desc 'Start application'
  task :start do
    on roles(:web), in: :sequence, wait: 5 do
      within release_path do
        execute :bundle , "exec unicorn_rails -c config/unicorn.rb -D -E #{fetch(:rails_env)}"
      end
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:web), in: :sequence, wait: 5 do
      execute "kill -s USR2 `cat #{fetch(:unicorn_pid)}`"
    end
  end

  desc 'Restart application'
  task :stop do
    on roles(:web), in: :sequence, wait: 5 do
      execute :kill, "-s QUIT `cat #{fetch(:unicorn_pid)}`"
    end
  end

  desc "Check server status"
  task :status do
    on roles(:web), in: :sequence, wait: 5 do
      if unicorn_is_running?
        puts "Unicorn is running"
      else
        puts "Unicorn is not running"
      end
    end
  end

  desc "Open the rails console on each of the remote servers"
  task :console do
    on roles(:worker), :primary => true do |host| #does it for each host, bad.
      execute_interactively "bundle exec rails console #{fetch(:rails_env)}"
    end
  end

  desc "Open the rails dbconsole on each of the remote servers"
  task :dbconsole do
    on roles(:worker), :primary => true do |host| #does it for each host, bad.
      rails_env = fetch(:stage)
      execute_interactively "bundle exec rails dbconsole #{fetch(:rails_env)}"
    end
  end

  def unicorn_is_running?
    unicorn_is_running = false
    if test("[ -f #{fetch(:unicorn_pid)} ]")
      begin
        result = execute "ps -o pid= -p `cat #{fetch(:unicorn_pid)}`"
        unicorn_is_running = true
      rescue
        unicorn_is_running = false
      end
    else
      unicorn_is_running = false
    end

    return unicorn_is_running
  end
end

namespace :deploy do

  # desc 'Restart application'
  # task :restart do
  #   on roles(:app), in: :sequence, wait: 5 do
  #     # Your restart mechanism here, for example:
  #     # execute :touch, release_path.join('tmp/restart.txt')
  #   end
  # end

  # after :publishing, :restart

  # after :restart, :clear_cache do
  #   on roles(:web), in: :groups, limit: 3, wait: 10 do
  #     # Here we can do anything such as:
  #     # within release_path do
  #     #   execute :rake, 'cache:clear'
  #     # end
  #   end
  # end
  
  after 'deploy:finishing', 'rails:stop'
  after 'deploy:finishing', 'rails:start'
end

def execute_interactively(command)
  port = fetch(:ssh_options)[:port] || 22
  exec_command = %Q(ssh -i #{fetch(:ssh_options)[:keys].first} -p #{port} #{fetch(:ssh_options)[:user]}@#{host} "source /usr/local/rvm/environments/default;cd #{deploy_to}/current; #{command}")

  puts exec_command
  exec exec_command
end