module Aurum
  

  class Target
    attr_accessor :name, :configuration, :file_name, :libraries, :requires, :contents

    def initialize(name, includes, requires, configuration)
      @name, @requires, @configuration = name, requires, configuration
      @file_name = "#{@name}.aur"
      @target_name = "#{@name}.sol"
      @libraries = includes.nil? ? nil : includes.collect {|x| Library.new(x, configuration)} 
      @contents = File.read(File.join(configuration.source_dir, @file_name))
    end

    def render
      target_file = File.join(configuration.target_dir, @target_name)
      f = File.new(target_file, 'w')
      @libraries.each do |library|
        f << library.contents
        f << "\n"
        f << "\n"
      end unless @libraries.nil?
      @requires.each do |req|
        payload = configuration.get_abi(req).payload
        f << payload
        f << "\n"
        f << "\n"
      end unless @requires.nil?
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