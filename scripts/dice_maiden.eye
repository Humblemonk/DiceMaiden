# Ruby gem Eye config for process monitoring of Dice Maiden

cwd = File.expand_path(File.join(File.dirname(__FILE__), %w[../]))

Eye.config do
  logger "/opt/eye.log"
end

Eye.app 'dice_maiden' do
  working_dir cwd
  env 'BUNDLE_GEMFILE' => "Gemfile"
  trigger :flapping, times: 10, within: 1.minute, retry_in: 10.minutes
  check :memory, :below => 512.megabytes, :every => 30.seconds, :times => 5

  group 'shards' do
    chain grace: 2.seconds
    
    100.times do |i|
      process "dice_maiden#{i}" do
        pid_file "/tmp/dice_maiden#{i}.pid"
        start_command "bundle exec ruby dice_maiden.rb #{i}"
        stdall "dice_rolls.log"
        daemonize true
        start_grace 10.seconds
      end
    end
  end
end
