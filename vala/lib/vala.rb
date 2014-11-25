require "colorize"

class ValaCompile
  attr :project_name, :project_dir, :pkgs, :vala_options, :c_libs, :c_options, :files, :application_type

  def initialize(
    project_name: "default-project", project_dir: ".", pkgs: "", c_libs: "", 
    vala_options: "", c_options: "", files: "", application_type: "console")

    @valac = "#{VALA_DIR}/bin/valac"

    @application_type = application_type
    @project_name = project_name
    @project_dir = project_dir
    @pkgs = pkgs
    @vala_options = vala_options
    @c_libs = c_libs
    @c_options = c_options
    @files = files

  end

  def to_s 
    build_dir = "#{project_dir}/build"
    output = "--output=" << "#{build_dir}/#{project_name}".green

    @pkgs = @pkgs.split.collect do |x|
      "--pkg=" << "#{x}".green
    end

    @c_libs = @c_libs.split.collect do |x| 
      "--Xcc=" << "-l#{x}".green
    end

    @c_options = @c_options.split.collect do |x| 
      "--Xcc=" << "#{x}".green
    end

    @pkgs = @pkgs.join " "
    @c_libs = @c_libs.join " "
    @c_options = @c_options.join " "

    case @application_type
    when "console"
      @vala_options << "--Xcc=" << "-mconsole".green
    when "desktop"
      @vala_options << "--Xcc=" << "-mwindows".green
    when "shared-library"
      output << ".dll".green
      @c_options << " --Xcc=" << "-shared".green
      @vala_options << [
        "--library=" << "#{build_dir}/#{project_name}".green,
        "--header=" << "#{build_dir}/#{project_name}.h".green
      ].join(" ")
    end


    result = "#{@valac} #{output} #{@pkgs} #{@c_libs} #{@c_options} #{@vala_options} #{@files.to_s.yellow}"
    puts "Compile command: ".light_white
    puts "\t#{result}"
    puts ("-" * 50).light_white
    result.uncolorize
  end
end
