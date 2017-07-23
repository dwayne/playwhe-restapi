require 'rake'

ENV['RACK_ENV'] ||= 'development'

ENV['PLAYWHE_DATABASE_URL'] ||= File.join(File.dirname(__FILE__), 'data/playwhe.db')

namespace :thin do

  desc 'Start the app'
  task :start do
    puts 'Starting...'
    system "bundle exec thin -s 1 -C config/config-#{ENV['RACK_ENV']}.yml -R config/config.ru start"
    puts 'Started!'
  end

  desc 'Stop the app'
  task :stop do
    puts 'Stopping...'

    pids = File.join(File.dirname(__FILE__), 'tmp/pids')

    if File.directory?(pids)
      Dir.new(pids).each do |file|
        prefix = file.to_s
        if prefix[0, 4] == 'thin'
          puts "Stopping the server on port #{file[/\d+/]}..."
          system "bundle exec thin stop -Ptmp/pids/#{file}"
        end
      end
    end

    puts 'Stopped!'
  end

  desc 'Restart the application'
  task :restart do
    puts 'Restarting...'
    Rake::Task['thin:stop'].invoke
    Rake::Task['thin:start'].invoke
    puts 'Done!'
  end

end

user = 'dwaynecrooks'

app_name = 'playwhe_restapi'
app_dir  = "/home/#{user}/webapps/#{app_name}"

desc 'Deploy to server'
task :deploy, :password do |t, args|
  puts 'Deploying to server...'

  # http://linux.die.net/man/1/rsync
  # Push: rsync [OPTION...] SRC... [USER@]HOST:DEST
  success =  system "rsync --exclude-from .excludes -rltvz -e ssh . #{user}@web534.webfaction.com:#{app_dir}"

  if success
    require 'net/ssh'
    Net::SSH.start('web534.webfaction.com', user, :password => args[:password]) do |ssh|
      commands = [
        'export RACK_ENV=production',
        "export PLAYWHE_DATABASE_URL=/home/#{user}/.playwhe/playwhe.db",

        "cd #{app_dir}",
        'bundle install --without=development',

        'rake thin:restart'
      ].join ' && '

      ssh.exec commands
    end
  end
end
