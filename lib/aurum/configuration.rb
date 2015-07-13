module Aurum
  class SolidityError < StandardError
    attr_reader :object 
    def initialize(object)
      @object = object
    end
  end

  SOLIDITY_BINARY = "/usr/local/bin/solc"

  class Configuration
    attr_accessor :makefile, :targets, :source_dir, :target_dir, :sol_abi, :library_files, :target_files, :temp_dir

    def initialize(basedir)
      config = File.join(basedir, "makefile.yml")
      @makefile = YAML.load_file(config).with_indifferent_access
      @target_dir = @makefile[:target_dir]
      @source_dir = @makefile[:source_dir]
      @targets = @makefile[:contracts].collect do |t|
        target = t.with_indifferent_access
        Target.new(target[:name], target[:includes], target[:requires], self)
      end
      @target_files = @targets.collect {|x| x.file_name}

      @library_files = @targets.collect {|x| x.libraries}.compact.flatten.collect {|x| x.file_name}
      payload = []
      @library_files.uniq.each do |lf|
        filepath = File.join(@source_dir, lf)
        payload << File.readlines(filepath).collect(&:chomp)
      end
      @target_files.uniq.each do |tf|
        filepath = File.join(@source_dir, tf)
        payload << File.readlines(filepath).collect(&:chomp)
      end
      @temp_dir = Dir.mktmpdir
      solidity_payload = File.join(@temp_dir, "Project.sol")
      File.open(solidity_payload, 'w') do |f|
        f.puts payload.join("\n")
      end
      solidity_command = "#{SOLIDITY_BINARY} --combined-json sol-abi #{solidity_payload}"
      solin, solout, solerr = Open3.popen3(solidity_command)
      error = solerr.read
      unless error.empty?
        error_message = error.split("Project.sol")[1][1..-1]
        error_line = error_message.split(":")[0].to_i
        error_line_start = error_line - 5
        error_line_end = error_line + 5
        error_payload = File.readlines(solidity_payload).collect(&:chomp)[error_line_start.. error_line_end].join("\n")
        line = "━".blue * TermInfo.screen_size[1]
        puts line
        puts "#{error_message}".red
        puts "#{error_payload}".yellow
        puts line

        raise SolidityError, "Solidity compile error"
      end
      abidata = JSON.parse(solout.read.chomp.chomp)
      @sol_abi = abidata["contracts"].keys.collect do |k|
        Abi.new(k, abidata["contracts"][k]["sol-abi"])
      end
    end

    def get_abi(name)
      @sol_abi.detect {|x| x.name == name}
    end

    def process
      @targets.each do |target|
        target.render
      end
    end

  end
end