module Aurum


  class Project
    attr_accessor :source_dir, :temp_dir, :stage1_dir, :stage2_dir, :libraries, :sources, :target_dir

    def initialize(path, target)
      @source_dir = path
      @temp_dir = Dir.mktmpdir("aurum")
      @stage1_dir = File.join(@temp_dir, "stage1")
      @stage2_dir = File.join(@temp_dir, "stage2")
      FileUtils.mkdir(@stage1_dir)
      FileUtils.mkdir(@stage2_dir)
      @target_dir = target
      @libraries = Dir.glob("#{@source_dir}/*.lau").collect {|l| Library.new(l, self)}
      @sources = Dir.glob("#{@source_dir}/*.aur").collect {|s| Source.new(s, self)}
    end

    def get_library(name)
      @libraries.detect {|x| x.name == name}
    end

    def get_require(name)
      @sources.detect {|x| x.name == name}
    end

    def stage1
      @libraries.each {|x| x.stage1}
      @sources.each {|x| x.stage1}
    end

    def stage2
      @libraries.each {|x| x.stage2}
      @sources.each {|x| x.stage2}
    end

    def process
      stage1
      stage2
      FileUtils.mkdir(@target_dir) unless Dir.exists?(@target_dir)
      contents = Dir.glob("#{@stage2_dir}/*")
      contents.each do |content|
        FileUtils.cp(content, @target_dir)
      end
    end

  end
end