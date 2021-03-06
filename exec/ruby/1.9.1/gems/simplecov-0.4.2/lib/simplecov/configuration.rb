require 'fileutils'
#
# Bundles the configuration options used for SimpleCov. All methods
# defined here are usable from SimpleCov directly. Please check out
# SimpleCov documentation for further info.
#
module SimpleCov::Configuration
  attr_writer :filters, :groups, :formatter
  
  #
  # The root for the project. This defaults to the
  # current working directory.
  #
  # Configure with SimpleCov.root('/my/project/path')
  #
  def root(root=nil)
    return @root if @root and root.nil?
    @root = File.expand_path(root || Dir.getwd)
  end
  
  #
  # The name of the output and cache directory. Defaults to 'coverage'
  #
  # Configure with SimpleCov.coverage_dir('cov')
  #
  def coverage_dir(dir=nil)
    return @coverage_dir if @coverage_dir and dir.nil?
    @coverage_dir = (dir || 'coverage')
  end
  
  #
  # Returns the full path to the output directory using SimpleCov.root
  # and SimpleCov.coverage_dir, so you can adjust this by configuring those
  # values. Will create the directory if it's missing
  #
  def coverage_path
    coverage_path = File.join(root, coverage_dir)
    FileUtils.mkdir_p coverage_path
    coverage_path
  end
  
  # 
  # Returns the list of configured filters. Add filters using SimpleCov.add_filter.
  #
  def filters
    @filters ||= []
  end
  
  # The name of the command (a.k.a. Test Suite) currently running. Used for result
  # merging and caching. It first tries to make a guess based upon the command line
  # arguments the current test suite is running on and should automatically detect
  # unit tests, functional tests, integration tests, rpsec and cucumber and label
  # them properly. If it fails to recognize the current command, the command name
  # is set to the shell command that the current suite is running on.
  #
  # You can specify it manually with SimpleCov.command_name("test:units") - please
  # also check out the corresponding section in README.rdoc
  def command_name(name=nil)
    @name = name unless name.nil?
    @name ||= SimpleCov::CommandGuesser.guess("#{$0} #{ARGV.join(" ")}")
    @name
  end
  
  #
  # Gets or sets the configured formatter.
  #
  # Configure with: SimpleCov.formatter(SimpleCov::Formatter::SimpleFormatter)
  #
  def formatter(formatter=nil)
    return @formatter if @formatter and formatter.nil?
    @formatter = formatter
    raise "No formatter configured. Please specify a formatter using SimpleCov.formatter = SimpleCov::Formatter::SimpleFormatter" unless @formatter
    @formatter
  end
  
  #
  # Returns the configured groups. Add groups using SimpleCov.add_group
  #
  def groups
    @groups ||= {}
  end
  
  #
  # Returns the hash of available adapters
  #
  def adapters
    @adapters ||= SimpleCov::Adapters.new
  end
  
  #
  # Allows you to configure simplecov in a block instead of prepending SimpleCov to all config methods
  # you're calling.
  #
  # SimpleCov.configure do
  #   add_filter 'foobar'
  # end
  #
  # This is equivalent to SimpleCov.add_filter 'foobar' and thus makes it easier to set a buchn of configure
  # options at once.
  #
  def configure(&block)
    return false unless SimpleCov.usable?
    instance_exec(&block)
  end
  
  #
  # Gets or sets the behavior to process coverage results.
  #
  # By default, it will call SimpleCov.result.format!
  #
  # Configure with:
  #   SimpleCov.at_exit do
  #     puts "Coverage done"
  #     SimpleCov.result.format!
  #   end
  #
  def at_exit(&block)
    return Proc.new {} unless running or block_given?
    @at_exit = block if block_given?
    @at_exit ||= Proc.new { SimpleCov.result.format! }
  end
  
  #
  # Returns the project name - currently assuming the last dirname in
  # the SimpleCov.root is this.
  #
  def project_name(new_name=nil)
    return @project_name if @project_name and new_name.nil?
    @project_name = new_name if new_name.kind_of?(String)
    @project_name ||= File.basename(root.split('/').last).capitalize.gsub('_', ' ')
  end
  
  #
  # Defines whether to use result merging so all your test suites (test:units, test:functionals, cucumber, ...)
  # are joined and combined into a single coverage report
  #
  def use_merging(use=nil)
    @use_merging = use unless use.nil? # Set if param given
    @use_merging = true if @use_merging != false
  end
  
  #
  # Defines them maximum age (in seconds) of a resultset to still be included in merged results.
  # i.e. If you run cucumber features, then later rake test, if the stored cucumber resultset is 
  # more seconds ago than specified here, it won't be taken into account when merging (and is also
  # purged from the resultset cache)
  #
  # Of course, this only applies when merging is active (e.g. SimpleCov.use_merging is not false!)
  #
  # Default is 600 seconds (10 minutes)
  #
  # Configure with SimpleCov.merge_timeout(3600) # 1hr
  #
  def merge_timeout(seconds=nil)
    @merge_timeout = seconds if !seconds.nil? and seconds.kind_of?(Fixnum)
    @merge_timeout ||= 600
  end
  
  #
  # Add a filter to the processing chain.
  # There are three ways to define a filter:
  # 
  # * as a String that will then be matched against all source files' file paths,
  #   SimpleCov.add_filter 'app/models' # will reject all your models
  # * as a block which will be passed the source file in question and should either
  #   return a true or false value, depending on whether the file should be removed
  #   SimpleCov.add_filter do |src_file|
  #     File.basename(src_file.filename) == 'environment.rb'
  #   end # Will exclude environment.rb files from the results
  # * as an instance of a subclass of SimpleCov::Filter. See the documentation there
  #   on how to define your own filter classes
  #
  def add_filter(filter_argument=nil, &filter_proc)
    filters << parse_filter(filter_argument, &filter_proc)
  end
  
  #
  # Define a group for files. Works similar to add_filter, only that the first
  # argument is the desired group name and files PASSING the filter end up in the group
  # (while filters exclude when the filter is applicable).
  #
  def add_group(group_name, filter_argument=nil, &filter_proc)
    groups[group_name] = parse_filter(filter_argument, &filter_proc)
  end
  
  #
  # The actal filter processor. Not meant for direct use
  #
  def parse_filter(filter_argument=nil, &filter_proc)
    if filter_argument.kind_of?(SimpleCov::Filter)
      filter_argument
    elsif filter_argument.kind_of?(String)
      SimpleCov::StringFilter.new(filter_argument)
    elsif filter_proc
      SimpleCov::BlockFilter.new(filter_proc)
    else
      raise ArgumentError, "Please specify either a string or a block to filter with"
    end      
  end
end