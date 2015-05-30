#!/usr/bin/ruby

require "erb"

if ARGV.size != 2
    puts "#$0 <pkg_name> <input_file>"
    exit 1
end

$curr_dir = File.dirname($0)

pkg = ARGV.shift
input_file = ARGV.shift

token_type_prefix = pkg.upcase + "_TOKEN_TYPE_"

token_types = []
flex_rules = ""
nonterminal_types = []
state = -1
File.open(input_file, "r") do |f|
    f.each_line do |line|
        line.rstrip!
        if line == "@@FLEX"
            state = 0
            next
        elsif line == "@@PEG"
            state = 1
            next
        end
        if state == 0
            m = line.match(/return\s+\@(\w+)/)
            if !m.nil?
                token_type, = m.captures
                token_types.push(token_type)
                line.gsub!("@"+token_type, token_type_prefix+token_type)
            end
            flex_rules += line + "\n"
        else state == 1
            line.lstrip!
            if line != ""
                nonterminal_types.push(line.lstrip)
            end
        end
    end
end

token_types.uniq!
nonterminal_types.uniq!

class NameMgr
    def initialize(pkg, token_type_prefix, token_types,
                   flex_rules, nonterminal_types)
        @pkg = pkg
        @token_type_prefix = token_type_prefix
        @token_types = token_types
        @flex_rules = flex_rules
        @nonterminal_types = nonterminal_types
    end

    def get_binding
        binding
    end
end

$name_mgr = NameMgr.new(pkg, token_type_prefix, token_types,
                        flex_rules, nonterminal_types)

def gen_file(pkg, target)
    fname = pkg + "_" + target
    tmpl = $curr_dir + "/" + target + ".tmpl"
    File.open(fname, "w") do |f|
        erb = ERB.new(File.read(tmpl), 0, '>')
        f.write(erb.result($name_mgr.get_binding))
        puts("Generated #{fname}")
    end
end

gen_file(pkg, "token_type_def.h")
gen_file(pkg, "token_type_def.c")
gen_file(pkg, "flex.l")
cmd = "flex #{pkg}_flex.l"
puts("Run #{cmd}")
system(cmd)
gen_file(pkg, "error.h")
gen_file(pkg, "error.cpp")
gen_file(pkg, "read_stream.h")
gen_file(pkg, "read_stream.cpp")
gen_file(pkg, "stream_reader.h")
gen_file(pkg, "stream_reader.cpp")
gen_file(pkg, "token_type.h")
gen_file(pkg, "token_type.cpp")
gen_file(pkg, "token.h")
gen_file(pkg, "token.cpp")
gen_file(pkg, "lexer.h")
gen_file(pkg, "lexer.cpp")
gen_file(pkg, "nonterminal_type.h")
gen_file(pkg, "nonterminal_type.cpp")
