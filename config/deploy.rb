require 'bundler/capistrano' #サーバーでも勝手にバンドル走る
set :use_sudo, false #ルート以外もつかうため

set :application, "hello"
set :repository,  "git@github.com:ogawakeisuke/hello.git"

set :scm, :git
set :branch, "master"#gitのブランチ情報
set :user, "hello"
set :deploy_to, "/home/#{user}/app/#{application}" #誰がデプロイしてるか
ssh_options[:forward_agent] = true

set :deploy_via, :copy  #サーバ上にコピー　必要
set :git_shallow_clone, 1 #クローンは直前

role :web, "133.242.48.15"                          # Your HTTP server, Apache/etc
role :app, "133.242.48.15"                          # This may be the same as your `Web` server
role :db,  "133.242.48.15"

set :default_environment, {
 'PATH' => "~/.rbenv/shims/:~/.rbenv/bin/:$PATH" #コロンはそれぞれパスを探している
}

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
#namespace :deploy do
#   task :start do end #cap deploy:startというコマンドをローカルで入れる
#   task :stop do ; end	#cap deploy:stop
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
set :unicorn_config, "#{current_path}/config/unicorn.rb"
set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"

namespace :deploy do
  task :start, :roles => :app, :except => { :no_release => true } do 
    run "cd #{current_path} && BUNDLE_GEMFILE=#{current_path}/Gemfile bundle exec unicorn -c #{unicorn_config} -E #{rails_env} -D"
  end
  task :stop, :roles => :app, :except => { :no_release => true } do 
    run "kill `cat #{unicorn_pid}`"
  end
  task :graceful_stop, :roles => :app, :except => { :no_release => true } do
    run "kill -s QUIT `cat #{unicorn_pid}`"
  end
  task :reload, :roles => :app do
    run "kill -s USR2 `cat #{unicorn_pid}`"
  end
 # task :restart, :roles => :app, :except => { :no_release => true } do
  #  stop
   # start
  #end
end