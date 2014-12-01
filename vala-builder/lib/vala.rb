require "yaml"
require "fileutils"
require "colorize"
require "rake"

include FileUtils

class ValaBuilder

  def initialize
    @file = YAML.load_file("Valafile")

    @bin = "#{ENV["VALA_DIR"].gsub("\\", "/")}/bin"
    @lib = "#{ENV["VALA_DIR"].gsub("\\", "/")}/lib"
    @include = "#{ENV["VALA_DIR"].gsub("\\", "/")}/include"
    @vapi = ENV["VAPI_DIR"].gsub("\\", "/")

    ENV["PATH"] = "#{ENV["PATH"]};#{@bin}"

    names = @file.map do |x|
      x["name"].length
    end


    @aligment = names.max + 2

    mkdir_p(@file.map { |f| "build/#{f["name"]}" })

    @file = @file.select { |x| x["name"] == ARGV[0] } if ARGV.length > 0

    @file.each do |project|
      tasks = ["compile"]

      tasks << "deps" if project["type"].nil? or project["type"] == "console" or project["type"] == "desktop"
      tasks << "inst-lib" if project["type"] == "shared-library"


      tasks = tasks.select { |t| ARGV[1].split(":").include? t } if ARGV.length > 1

      tasks.each { |t| 
        profile(String.new(project["name"]), t) { self.task t, project }
      }
    end
  end

  def task(name, project)
    case name
    when "compile"
      self.compile project
    when "deps"
      self.deps project
    when "inst-lib"
      self.install_library project
    end
  end

  def compile(project)
    pkgs = project["pkgs"].nil? ? [] : project["pkgs"].split(" ")
    vala_flags = project["vala_flags"].nil? ? [] : project["vala_flags"].split(" ")
    clibs = project["clibs"].nil? ? [] : project["clibs"].split(" ")
    cflags = project["cflags"].nil? ? [] : project["cflags"].split(" ")
    files = project["files"].nil? ? [] : project["files"].split(" ")

    pkgs.each do |pkg|
      pkgs += File.open("#{@vapi}/#{pkg}.deps").each_line.to_a if File.exist?("#{@vapi}/#{pkg}.deps")
    end

    pkg_list = `pkg-config --list-all`.lines.map { |x| x.split[0] }
    cpkg = pkgs.select { |x| pkg_list.include? x }

    cflags += `pkg-config --libs --cflags #{cpkg.join(" ") }`.split(" ").map { |f| "#{f}" } if pkgs.length > 0

    case project["type"]
    when "console"
      cflags << "-mconsole"

      vala_flags += [
        "--output=#{File.expand_path("build/#{project["name"]}/#{project["name"]}")}"
      ]
    when "desktop"
      cflags << "-mwindows"

      vala_flags += [
        "--output=#{File.expand_path("build/#{project["name"]}/#{project["name"]}")}"
      ]
    when "shared-library"
      cflags << "-shared"

      vala_flags += [
        "--library=build/#{project["name"]}/#{project["name"]}",
        "--header=build/#{project["name"]}/#{project["name"]}.h",
        "--output=#{File.expand_path("build/#{project["name"]}/#{project["name"]}")}.dll"
      ]

      File.open("build/#{project["name"]}/#{project["name"]}.pc", "w") { |f| 
        text = """
          prefix=/opt
          exec_prefix=${prefix}
          libdir=${exec_prefix}/lib
          includedir=${prefix}/include


          Name: #{project["name"]}
          Description:
          Version:
          Requires.private: 
          Libs: -L${libdir} -l#{project["name"]}
          Libs.private:
          Cflags: -I${includedir} -I${libdir}
        """.lines.collect do |x| 
          x.lstrip 
        end

        f.write text.join
      }

      File.open("build/#{project["name"]}/#{project["name"]}.deps", "w") { |f|
        f.write pkgs.uniq.join "\n"
      }

    else
      vala_flags += [
        "--output=#{File.expand_path("build/#{project["name"]}/#{project["name"]}")}"
      ]
    end

    pkgs_args = pkgs.map { |p| "--pkg=#{p}" }
    vala_flags_args = vala_flags.map { |f| "#{f}" }
    clibs_args = clibs.map { |l| "--Xcc=-l#{l}" }
    cflags_args = cflags.map { |f| "--Xcc=#{f}" }
    files_args = Rake::FileList.new(files)

    system "valac #{files_args.uniq.join " "} #{pkgs_args.uniq.join " " } #{vala_flags_args.uniq.join " "} #{clibs_args.uniq.join " "} #{cflags_args.uniq.join " "}".delete("\n")
  end

  def deps(project)
    pkgs = project["pkgs"].nil? ? [] : project["pkgs"].split(" ")
    pkg_list = `pkg-config --list-all`.lines.map { |x| x.split[0] }
    clibs = project["clibs"].nil? ? [] : project["clibs"].split(" ")

    pkgs.each do |pkg|
      pkgs += File.open("#{@vapi}/#{pkg}.deps").each_line.to_a if File.exist?("#{@vapi}/#{pkg}.deps")
    end

    pkgs = pkgs.map { |x| x.delete("\n") }

    pkg_list = `pkg-config --list-all`.lines.map { |x| x.split[0] }
    cpkg = pkgs.select { |x| pkg_list.include? x }

    clibs += `pkg-config --libs #{cpkg.join(" ").delete("\n")}`.split(" ").map { |f| "#{f}" } if pkgs.length > 0
    bin_list = Rake::FileList["#{@bin}/*.dll"]

    clibs = clibs[1..-1].map { |x| x[2..-1] }
    clibs = clibs.select { |x| x.length > 1 and not x.include?(",") }

    copy = []
    clibs.each { |l| 
      copy += bin_list.select { |dll| dll.upcase.match(Regexp.new("#{l.upcase}")) }
    }

    copy.uniq.each do |c|
      cp c, "build/#{project["name"]}/#{File.basename c}"
    end

    [
      "#{@bin}/libglib-2.0-0.dll",
      "#{@bin}/libgobject-2.0-0.dll", 
      "#{@bin}/libgcc_s_dw2-1.dll",
      "#{@bin}/libpng15-15.dll",
      "#{@bin}/libexpat-1.dll",
      "#{@bin}/libgmodule-2.0-0.dll",
      "#{@bin}/libpixman-1-0.dll",
    ].each do |c|
      cp c, "build/#{project["name"]}/#{File.basename c}"
    end
  end

  def install_library(project)
    project_build = "build/#{project["name"]}/#{project["name"]}"
    cp "#{project_build}.dll", "#{@bin}/#{project["name"]}.dll"
    cp "#{project_build}.h", "#{@include}/#{project["name"]}.h"
    cp "#{project_build}.dll", "#{@lib}/lib#{project["name"]}.dll.a"
    cp "#{project_build}.vapi", "#{@vapi}/#{project["name"]}.vapi"
    cp "#{project_build}.deps", "#{@vapi}/#{project["name"]}.deps"
    cp "#{project_build}.pc", "#{ENV["PKG_CONFIG_PATH"]}/#{project["name"]}.pc"
  end

  def profile(name, task)
    start_time = Time.new
    yield
    elapsed = Time.at(Time.new - start_time).gmtime.strftime "%H:%M:%S.%L"
    puts "#{name << ":" << " " * (@aligment - name.length)}".light_white << "#{task << " " * (15 - task.length)}".light_magenta << " " << "[".light_white << "#{elapsed}".light_green << "]".light_white
  end
end
