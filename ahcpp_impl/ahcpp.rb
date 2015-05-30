#!/usr/bin/ruby

require "erb"

if ARGV.size != 2
    puts "#$0 <pkg_name> <class_name>"
    exit 1
end

$curr_dir = File.dirname($0)

pkg_name = ARGV.shift
class_name = ARGV.shift

class NameMgr
    attr_reader :h_file_name
    attr_reader :cpp_file_name
    attr_reader :t_cpp_file_name
    
    def initialize(pkg_name, class_name)
        @pkg_name = pkg_name
        @class_name = class_name
        
        class_name_elems = @class_name.split /(?=[A-Z])/
        class_name_elems_l = class_name_elems.map{ |x| x.downcase }
        file_prefix = pkg_name + "_" + class_name_elems_l.join("_")

        @ns = @pkg_name
        
        @h_file_name = file_prefix + ".h"
        @h_guard = "INCLUDED_" + file_prefix.upcase + "_H"

        @cpp_file_name = file_prefix + ".cpp"

        @t_cpp_file_name = file_prefix + ".t.cpp"
    end

    def get_binding
        binding
    end
end

name_mgr = NameMgr.new(pkg_name, class_name)

File.open(name_mgr.h_file_name, "w") do |f|
    h_tmpl = File.read($curr_dir + "/h.tmpl")
    h_tmpl_erb = ERB.new(h_tmpl)
    f.write h_tmpl_erb.result(name_mgr.get_binding)
    puts "Generated #{name_mgr.h_file_name}"
end

File.open(name_mgr.cpp_file_name, "w") do |f|
    cpp_tmpl = File.read($curr_dir + "/cpp.tmpl")
    cpp_tmpl_erb = ERB.new(cpp_tmpl)
    f.write cpp_tmpl_erb.result(name_mgr.get_binding)
    puts "Generated #{name_mgr.cpp_file_name}"
end

File.open(name_mgr.t_cpp_file_name, "w") do |f|
    t_cpp_tmpl = File.read($curr_dir + "/t_cpp.tmpl")
    t_cpp_tmpl_erb = ERB.new(t_cpp_tmpl)
    f.write t_cpp_tmpl_erb.result(name_mgr.get_binding)
    puts "Generated #{name_mgr.t_cpp_file_name}"
end
