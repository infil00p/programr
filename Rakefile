#Rakefile
require "rake/testtask"
require "rake/clean"
require "rake/rdoctask"
require "rake/gempackagetask"

PROJECT = "ProgramR"
MY_NAME = "Mauro Cicio, Nicholas H.Tollervey and Ben Minton"
MY_EMAIL = "mauro [at] cicio.org, ntoll [at] ntoll.org, bdminton [at] gmail.com"
PROJECT_SUMMARY = "ProgramR is a Ruby implementation of an interpreter for the Artificial Intelligence Markup Language (AIML) based on the work of Dr. Wallace and defined by the Alicebot and AIML Architecture Committee of the A.L.I.C.E. AI Foundation (http://alicebot.org)"
UNIX_NAME = "aiml-programr"
RUBYFORGE_USER = ENV["RUBYFORGE_USER"] || "ntoll"
WEBSITE_DIR = "website"
RDOC_HTML_DIR = "#{WEBSITE_DIR}/rdoc"

# Grab the VERSION constant
REQUIRE_PATHS = ["lib"]
$LOAD_PATH.concat(REQUIRE_PATHS)
require "#{UNIX_NAME}"
PROJECT_VERSION = eval("#{PROJECT}::VERSION")
#puts "PROJECT_VERSION set to: " + PROJECT_VERSION

CLOBBER.include(".config")

# Options common to RDocTask AND Gem::Specification.
# The --main argument specifies which file appears on the index.html page
GENERAL_RDOC_OPTS = {
    "--title" => "#{PROJECT} API Documentation",
    "--main" => "README.rdoc"
}

RDOC_FILES = FileList["README.rdoc", "Changes.rdoc"]

# Ruby library code
LIB_FILES = FileList["lib/**/*.rb"]
# puts "LIB_FILES: " 
# LIB_FILES.each { |file| puts file }

# Test::Unit test case file list
TEST_FILES = FileList["test/**/test_*.rb"]
# puts "TEST_FILES: "
# TEST_FILES.each { |test| puts test }

# Executable scripts and all non-garbage files under bin/
BIN_FILES = FileList["bin/*"]
# puts "BIN_FILES: "
# BIN_FILES.each { | bin_file | puts bin_file }
 
# This filelist is used to create the source package
# Include all Ruby and RDoc files
DIST_FILES = FileList["**/*.rb", "**/*.rdoc"]
DIST_FILES.include("Rakefile", "COPYING")
DIST_FILES.include(BIN_FILES)
DIST_FILES.include("data/**/*", "test/data/**/*")
DIST_FILES.include("#{WEBSITE_DIR}/**/*.{html,css}", "man/*.[0-9]")
# Don't package files that are autogenerated by RDocTask
DIST_FILES.exclude(/^(\.\/)?#{RDOC_HTML_DIR}(\/|$)/)
# Don't package temporary files perhaps created by tests
DIST_FILES.exclude("**/temp_*", "**/*.tmp")
# Don't get into recursion
DIST_FILES.exclude(/^(\.\/)?pkg(\/|$)/)

# Run the tests if rake is invoked without arguments
task "default" => ["test"]

test_task_name = "test"
Rake::TestTask.new("test") do |t|
    t.test_files = TEST_FILES
end

# the rdoc task generates API documentation
Rake::RDocTask.new("rdoc") do |t|
    t.rdoc_files = RDOC_FILES + LIB_FILES
    t.title = GENERAL_RDOC_OPTS["--title"]
    t.main = GENERAL_RDOC_OPTS["--main"]
    t.rdoc_dir = RDOC_HTML_DIR
end

GEM_SPEC = Gem::Specification.new do |s|
    s.name = UNIX_NAME
    s.version = PROJECT_VERSION
    s.summary = PROJECT_SUMMARY
    s.rubyforge_project = UNIX_NAME
    s.homepage = "http://#{UNIX_NAME}.rubyforge.org/"
    s.author = MY_NAME
    s.email = MY_EMAIL
    s.files = DIST_FILES
    s.test_files = TEST_FILES
    s.executables = BIN_FILES.map { |fn| File.basename(fn) }
    s.has_rdoc = true
    s.extra_rdoc_files = RDOC_FILES
    s.rdoc_options = GENERAL_RDOC_OPTS.to_a.flatten
end

# Task to publish RDoc and static HTML to Rubyforge
desc "Upload website to Rubyforge. "+
    "scp will prompt you for your RubyForge password."
task "publish-website" => ["rdoc"] do
    rubyforge_path = "/var/www/gforge-projects/#{UNIX_NAME}/"
    sh "scp -r #{WEBSITE_DIR}/* " +
        "#{RUBYFORGE_USER}@rubyforge.org:#{rubyforge_path}",
        :verbose => true
end

# Task to setup the rubyforge command 
desc "Setup the rubyforge command to work correctly with this "+
	"Rakefile."
task "rubyforge-setup" do
    unless File.exists?(File.join(ENV["HOME"], ".rubyforge"))
        puts "RubyForge will ask you to edit its config.yml now."
        puts "Please set the 'username' and 'password' entries"
        puts "to your RubyForge username and RubyForge password!"
        puts "Press ENTER to continue."
        $stdin.gets
        sh "rubyforge setup", :verbose => true
    end
end

task "rubyforge-login" => ["rubyforge-setup"] do
    # Note: we assume that username and password were set in
    # rubyforge's config.yml
    sh "rubyforge login", :verbose => true
end

task "publish-packages" => ["package", "rubyforge-login"] do
    # Upload packages under pkg/ to Rubyforge
    # This task makes some assumptions:
    # * You have already created a package on the "Files" tab on the
    #   RubyForge project page. See pkg_name variable below.
    # * You made entries under package_ids and group_ids for this
    #   project in rubyforge's config.yml. If not, eventually read
    #   "rubyforge --help" and then run "rubyforge setup"
    pkg_name = ENV["PKG_NAME"] || UNIX_NAME
    cmd = "rubyforge add_release #{UNIX_NAME} #{pkg_name} " +
        "#{PROJECT_VERSION} #{UNIX_NAME}-#{PROJECT_VERSION}"
    cd "pkg" do
        sh(cmd + ".gem", :verbose => true)
        sh(cmd + ".tgz", :verbose => true)
        sh(cmd + ".zip", :verbose => true)
    end
end

# The "pre-release" task makes sure your tests run, and then generates
# files for the new release.
desc "Run tests, generate RDoc and create packages."
task "prepare-release" => ["clobber"] do
    puts "Preparing release of #{PROJECT} version #{VERSION}"
    Rake::Task["test"].invoke
    Rake::Task["rdoc"].invoke
    Rake::Task["package"].invoke
end

# The "publish" task is the overarching task for the whole project. It 
# builds a release and the publishes it to RubyForge.
desc "Publish new release of #{PROJECT}"
task "publish" => ["prepare-release"] do
    puts "Uploading documentation..."
    Rake::Task["publish-website"].invoke
    puts "Checking for rubyforge command..."
    'rubyforge --help'
    if $? ==0
        puts "Uploading packages..."
        Rake::Task["publish-packages"].invoke
        puts "Release done!"
    else
        puts "Can't invoke rubyforge command."
        puts "Either install rubyforge with 'gem install rubyforge'"
        puts "and retry or upload the package files manually!"
    end
end