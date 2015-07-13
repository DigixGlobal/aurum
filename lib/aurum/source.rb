module Aurum
  SOLIDITY_BINARY = "/usr/local/bin/solc"

  module Util
    def header_to_name(header)
      header.gsub(/(\[|\])/, "").split(" ")[1]
    end
  end

  class Source

    INCLUDE_PATTERN = /#include\s\[\w*\]/
    REQUIRE_PATTERN = /#require\s\[\w*\]/

    include Util

    attr_accessor :name, :raw, :libraries, :requires, :project, :stage1_contents, :as_require, :stage1_path, :stage2_path, :stage2_contents

    def initialize(path, project)
      @name = File.basename(path).gsub(/\.aur/, "")
      @raw = File.readlines(path).collect(&:chomp)
      @project = project
      @libraries = @raw.select {|x| INCLUDE_PATTERN.match(x).present? }.collect {|x| x.gsub(/(\[|\])/, "").split(" ")[1]}
      @requires = @raw.select {|x| REQUIRE_PATTERN.match(x).present? }.collect {|x| x.gsub(/(\[|\])/, "").split(" ")[1]}
    end

    def stage1
      target = File.join(project.stage1_dir, "#{@name}.sol")
      contents = []
      @raw.each do |x|
        if INCLUDE_PATTERN.match(x)
          include_file = header_to_name(x)
          begin
            include_file_contents = project.get_library(include_file).raw
            contents.concat(include_file_contents)
          rescue NoMethodError
            raise RuntimeError, "Required library '#{include_file}.lau' from #{@name}.aur could not be found."
          end
        else
          contents << x
        end
      end
      File.open(target, 'w') do |f|
        f.puts contents.join("\n")
      end
      @stage1_path = target
      @stage1_contents = File.readlines(target).collect(&:chomp)
    end

    def stage2
      target = File.join(project.stage2_dir, "#{@name}.sol")
      contents = []
      @stage1_contents.each do |x|
        if REQUIRE_PATTERN.match(x)
          require_file = header_to_name(x)
          begin
            require_file_stage1_path = project.get_require(require_file).stage1_path
            solc_command = "#{Aurum::SOLIDITY_BINARY} --combined-json sol-abi #{require_file_stage1_path}"
            output = IO.popen(solc_command) {|x| x.read.chomp.chomp.chomp }
          rescue NoMethodError
            raise RuntimeError, "Required contract '#{require_file}.aur' from #{@name}.aur could not be found."
          end
          begin
            require_file_contents = JSON.parse(output)["contracts"][require_file]["sol-abi"]
            contents << require_file_contents
          rescue JSON::ParserError
            raise RuntimeError, "Solidity syntax error in #{require_file}.aur" 
          end
        else
          contents << x
        end
        File.open(target, 'w') do |f|
          f.puts contents.join("\n")
        end
        @stage2_path = target
        @stage2_contents = File.readlines(target).collect(&:chomp)

      end
    end

  end

  class Library

    attr_accessor :name, :raw, :project, :stage1_path, :stage1_contents, :stage2_path, :stage2_contents

    def initialize(path, project)
      @name = File.basename(path).gsub(/\.lau/, "")
      @raw = File.readlines(path).collect(&:chomp)
      @project = project
    end

    def stage1
      target = File.join(project.stage1_dir, "#{@name}.sol")
      File.open(target, 'w') do |f|
        f.puts @raw.join("\n")
      end
      @stage1_path = target
      @stage1_contents = File.readlines(target).collect(&:chomp)
    end

    def stage2
      target = File.join(project.stage2_dir, "#{@name}.sol")
      FileUtils.cp(@stage1_path, target)
      @stage2_path = target
      @stage2_contents = File.readlines(target).collect(&:chomp)
    end
  end

end