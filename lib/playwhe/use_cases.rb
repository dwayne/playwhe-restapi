Dir.glob(File.join(File.dirname(__FILE__), 'use_cases', '*.rb')).each do |path|
  require path
end
