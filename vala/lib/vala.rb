require "fileutils"
require "colorize"

include FileUtils

class Vala
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

  def self.profile_task(project_name, task_name)
    start_time = Time.new
    yield
    elapsed = Time.at(Time.new - start_time).gmtime.strftime "%H:%M:%S.%L"
    puts "#{project_name} [".light_white << "#{task_name}".light_magenta << "] [".light_white << "#{elapsed}".light_green << "]".light_white
  end 

  def self.install_library(name, project_dir: ".")
    copy_name = "#{project_dir}/build/#{name}"

    File.open("#{copy_name}.pc", "w") { |f| 
      text = """
        prefix=/opt
        exec_prefix=${prefix}
        libdir=${exec_prefix}/lib
        includedir=${prefix}/include


        Name: #{name}
        Description:
        Version:
        Requires.private: 
        Libs: -L${libdir} -l#{name}
        Libs.private:
        Cflags: -I${includedir} -I${libdir}
      """.lines.collect do |x| 
        x.lstrip 
      end

      f.write text.join
    }

    cp "#{copy_name}.dll",  "#{VALA_DIR}/bin/#{name}.dll"
    cp "#{copy_name}.dll",  "#{VALA_DIR}/lib/lib#{name}.a"
    cp "#{copy_name}.h",    "#{VALA_DIR}/include/#{name}.h"
    cp "#{copy_name}.pc",   "#{VALA_DIR}/lib/pkgconfig/#{name}.pc"
    cp "#{copy_name}.vapi", "#{VALA_VAPI_DIR}/#{name}.vapi"
  end

  def self.install_dependence(pkgs, project_dir: ".")
    deps = []

    pkgs.split(" ").each do |p|

      case p
      when "glib", "glib-2.0"
        deps += [
          "libglib-2.0-0.dll", 
          "libgobject-2.0-0.dll"
        ]
      when "gtk", "gtk+-3.0"
        deps += [
          "libglib-2.0-0.dll", 
          "libgobject-2.0-0.dll",
          "libgtk-3-0.dll",
          "libgdk-3-0.dll",
          "libatk-1.0-0.dll",
          "libcairo-2.dll",
          "libcairo-gobject-2.dll",
          "libgdk_pixbuf-2.0-0.dll",
          "libgio-2.0-0.dll",
          "libgmodule-2.0-0.dll",
          "libpango-1.0-0.dll",
          "libpangowin32-1.0-0.dll",
          "libpangocairo-1.0-0.dll",
          "libfontconfig-1.dll",
          "libfreetype-6.dll",
          "libpixman-1-0.dll",
          "libpng15-15.dll",
          "libpangoft2-1.0-0.dll",
          "libexpat-1.dll"
        ]
      else
        if File.exist?"#{VALA_DIR}/bin/lib#{p}.dll"
          deps << "lib#{p}.dll"
        elsif File.exist?"#{VALA_DIR}/bin/#{p}.dll"
          deps << "#{p}.dll"
        end
      end
    end

    deps.uniq.each { |e| cp "#{VALA_DIR}/bin/#{e}", "#{project_dir}/build/#{e}" }
  end

  def compile_s 
    build_dir = File.expand_path "#{project_dir}/build"
    output = "--output=" << "#{build_dir}/#{project_name}".green
    pkg_config_list = `pkg-config --list-all`.lines.map { |x| x.split[0] }
    pkg_clibs = ""

    @pkgs.split.each do |x|
      pkg_clibs << " #{x}" if pkg_config_list.include? x
    end

    pkg_options = `pkg-config --libs --cflags #{pkg_clibs}`.split.collect do |x|
      "--Xcc=" << "#{x}".green
    end 

    pkg_options = pkg_options.uniq.join(" ")

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
    @c_options = @c_options.join(" ") << pkg_options

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


    result = "#{@valac} -q #{@files.to_s.yellow} #{output} #{@pkgs} #{@c_libs} #{@c_options} #{@vala_options}"

    puts result

    result.uncolorize
  end
end
