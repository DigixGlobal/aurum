module Aurum
  class Make
    attr_accessor :source_dir, :configuration, :files, :contracts

    def initialize(dir)
      if Dir.exists?(dir)
        @source_dir = dir
        @files = Dir.glob("#{@source_dir}/*.aur")

        @contracts = []

        @files.each do |file|
          contents = File.readlines(file).collect(&:chomp)
          name = File.basename(file).gsub(/.aur/, "")
          includes = contents.grep(/#include/).collect {|x| x.chomp.gsub(/(\/\/#include\s|\]|\[)/, "") }
          requires = contents.grep(/#require/).collect {|x| x.chomp.gsub(/(\/\/#require\s|\]|\[)/, "") }
          @contracts << {"name" => name, "includes" => includes, "requires" => requires}
        end
        output = {"contracts" => @contracts}.to_yaml
        puts output
      end
    end

  end

  class Target
    attr_accessor :name, :configuration, :file_name, :libraries, :requires, :contents

    def initialize(name, includes, requires, configuration)
      @name, @requires, @configuration = name, requires, configuration
      @file_name = "#{@name}.aur"
      @target_name = "#{@name}.sol"
      @libraries = includes.collect {|x| Library.new(x, configuration)} 
      @contents = File.read(File.join(configuration.source_dir, @file_name))
    end

    def render
      target_file = File.join(configuration.target_dir, @target_name)
      f = File.new(target_file, 'w')
      @libraries.each do |library|
        f << library.contents
        f << "\n"
        f << "\n"
      end unless @libraries.empty?
      @requires.each do |req|
        payload = configuration.get_abi(req).payload
        f << payload
        f << "\n"
        f << "\n"
      end unless @requires.empty?
      f << "\n"
      f << "\n"
      f << contents
      f.close
    end
  end

  
  class Library
    attr_accessor :name, :file_name, :configuration, :source_path, :contents

    def initialize(name, configuration)
      @name, @configuration = name, configuration
      @file_name = "#{@name}.lau"
      @source_path = File.join(configuration.source_dir, @file_name)
      @contents = File.read(@source_path)
    end
  end

  class Abi

    attr_accessor :name, :payload

    def initialize(name, payload)
      @name, @payload = name, payload
    end

  end

end