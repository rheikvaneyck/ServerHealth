Gem::Specification.new do |s|
    s.name = "server-health"
    s.version = "0.1.0"
    s.authors = ["Marcus Nasarek", "Rheik van Eyck"]
    s.date = %q{2011-10-14}
    s.description = "Server-Health - parsing and visualizing health data from remote servers"
    s.summary = s.description
    s.email = "rheikvaneyck@yahoo.de"
    s.files = Dir["lib/**/*", "config/*", "template/*", "test/*", "*.txt", "README*"]
    s.bindir = "bin"
    s.executables = "server_health"
    s.homepage = "http://myname.plus/MarcusNasarek"
    s.has_rdoc = false
    s.rubyforge_project = "server_health"
    s.add_dependency('shoulda')
    s.add_dependency('net-scp')
    s.add_dependency('net-ssh')
    s.add_dependency('googlecharts')
    s.add_dependency('activerecord')
    s.add_dependency('sqlite3')    
end
    
    
