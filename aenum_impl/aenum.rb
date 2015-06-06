#!/usr/bin/ruby

require "erb"

if ARGV.size != 3
    puts "#$0 <pkg> <class_name> <input_file>"
    exit 1
end

$curr_dir = File.dirname($0)

pkg = ARGV.shift
class_name = ARGV.shift
input_file = ARGV.shift

enum_names = []
File.open(input_file, "r") do |f|
    f.each_line do |line|
        line.strip!
        if line != ""
            enum_names.push(line.strip)
        end
    end
end

enum_names.uniq!

class NameMgr
    attr_reader :h_file_name
    attr_reader :cpp_file_name
    attr_reader :t_cpp_file_name
    
    def initialize(pkg, class_name, enum_names)
        @pkg = pkg
        @class_name = class_name
        @enum_names = enum_names
        
        class_name_elems = @class_name.split /(?=[A-Z])/
        class_name_elems_l = class_name_elems.map{ |x| x.downcase }
        file_prefix = pkg + "_" + class_name_elems_l.join("_")
        
        @h_file_name = file_prefix + ".h"
        @h_guard = "INCLUDED_" + file_prefix.upcase + "_H"

        @cpp_file_name = file_prefix + ".cpp"

        @t_cpp_file_name = file_prefix + ".t.cpp"
    end

    def get_binding
        binding
    end
end

name_mgr = NameMgr.new(pkg, class_name, enum_names)

File.open(name_mgr.h_file_name, "w") do |f|
    h_tmpl = File.read($curr_dir + "/enum.h.tmpl")
    h_tmpl_erb = ERB.new(h_tmpl, 0, '>')
    f.write h_tmpl_erb.result(name_mgr.get_binding)
    puts "Generated #{name_mgr.h_file_name}"
end

File.open(name_mgr.cpp_file_name, "w") do |f|
    cpp_tmpl = File.read($curr_dir + "/enum.cpp.tmpl")
    cpp_tmpl_erb = ERB.new(cpp_tmpl, 0, '>')
    f.write cpp_tmpl_erb.result(name_mgr.get_binding)
    puts "Generated #{name_mgr.cpp_file_name}"
end
