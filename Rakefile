# Rakefile

desc "Run 'rbs prototype' with a given argument"
task :rbs_prototype, [:argument] do |t, args|
  if args[:argument].nil?
    puts "Usage: rake rbs_prototype[argument]"
    exit 1
  end

  sh "rbs prototype rb #{args[:argument]}"
end
