# Copyright (C) 2025 Jaromir Hradilek

# MIT License
#
# Permission  is hereby granted,  free of charge,  to any person  obtaining
# a copy of  this software  and associated documentation files  (the "Soft-
# ware"),  to deal in the Software  without restriction,  including without
# limitation the rights to use,  copy, modify, merge,  publish, distribute,
# sublicense, and/or sell copies of the Software,  and to permit persons to
# whom the Software is furnished to do so,  subject to the following condi-
# tions:
#
# The above copyright notice  and this permission notice  shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS",  WITHOUT WARRANTY OF ANY KIND,  EXPRESS
# OR IMPLIED,  INCLUDING BUT NOT LIMITED TO  THE WARRANTIES OF MERCHANTABI-
# LITY,  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT
# SHALL THE AUTHORS OR COPYRIGHT HOLDERS  BE LIABLE FOR ANY CLAIM,  DAMAGES
# OR OTHER LIABILITY,  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM,  OUT OF OR IN CONNECTION WITH  THE SOFTWARE  OR  THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

require 'optparse'
require 'pathname'
require 'asciidoctor'
require_relative 'version'
require_relative '../dita-topic'

module AsciidoctorDitaTopic
  class Cli
    def initialize name, argv
      @attr = ['experimental']
      @opts = {
        :output => false,
        :includes => true,
        :standalone => true,
        :map => false
      }
      @prep = []
      @name = name
      @args = self.parse_args argv
    end

    def parse_args argv
      parser = OptionParser.new do |opt|
        opt.banner  = "Usage: #{@name} [OPTION...] [FILE...]\n"
        opt.banner += "       #{@name} -h|-v\n\n"

        opt.on('-o', '--out-file FILE', 'specify the output file; by default, the output file name is based on the input file') do |output|
          @opts[:output] = (output.strip == '-') ? $stdout : output
        end

        opt.on('-a', '--attribute ATTRIBUTE', 'set a document attribute in the form of name, name!, or name=value pair; can be supplied multiple times') do |value|
          @attr.append value
        end

        opt.on('-s', '--no-header-footer', 'disable enclosing the content in <topic> and generating <title>') do
          @opts[:standalone] = false
        end

        opt.separator ''

        opt.on('-m', '--dita-map', 'generate a DITA map instead of a topic') do
          @opts[:map] = true
        end

        opt.on('-p', '--prepend-file FILE', 'prepend a file to all input files; can be supplied multiple times') do |file|
          raise OptionParser::InvalidArgument, "not a file: #{file}" unless File.exist? file and File.file? file
          raise OptionParser::InvalidArgument, "file not readable: #{file}" unless File.readable? file

          @prep.append file
        end

        opt.on('-I', '--no-includes', 'disable processing of include directives') do
          @opts[:includes] = false
        end

        opt.separator ''

        opt.on('-l', '--author-line', 'enable processing of author lines as metadata') do
          @attr.append 'dita-topic-authors=on'
        end

        opt.on('-t', '--section-type', 'add content type as outputclass to sections') do
          @attr.append 'dita-topic-type=on'
        end

        opt.on('-C', '--no-callouts', 'disable processing of callouts') do
          @attr.append 'dita-topic-callouts=off'
        end

        opt.on('-S', '--no-sidebars', 'disable processing of sidebars') do
          @attr.append 'dita-topic-sidebars=off'
        end

        opt.on('-T', '--no-titles', 'disable processing of floating titles') do
          @attr.append 'dita-topic-titles=off'
        end

        opt.separator ''

        opt.on('-h', '--help', 'display this help and exit') do
          puts opt
          exit
        end

        opt.on('-v', '--version', 'display version information and exit') do
          puts "#{@name} #{VERSION}"
          exit
        end
      end

      args = parser.parse argv

      if args.length == 0 or args[0].strip == '-'
        return [$stdin]
      end

      args.each do |file|
        raise OptionParser::InvalidArgument, "not a file: #{file}" unless File.exist? file and File.file? file
        raise OptionParser::InvalidArgument, "file not readable: #{file}" unless File.readable? file
      end

      return args
    end

    def convert_map file, input, output
      if file == $stdin
        base_dir = Pathname.new(Dir.pwd).expand_path
        offset   = 0
      else
        base_dir = Pathname.new(file).dirname.expand_path
        file     = Pathname.new(file).sub_ext('.dita').basename
        offset   = 1
      end

      doc        = Asciidoctor.load input, backend: 'dita-topic', safe: :unsafe, attributes: @attr, base_dir: base_dir, sourcemap: true
      sections   = doc.find_by context: :section

      return unless sections

      title      = (sections.first.level == 0 and sections.first.title) ? sections.first.title : false
      last_level = 0
      last_file  = ''

      if @opts[:standalone]
        result   = ["<?xml version='1.0' encoding='utf-8' ?>"]
        result  << %(<!DOCTYPE map PUBLIC "-//OASIS//DTD DITA Map//EN" "map.dtd">)
        result  << %(<map>)
        result  << %(  <title>#{title}</title>) if title
      else
        result   = []
      end

      sections.each_index do |i|
        section  = sections[i]
        level    = section.level
        title    = section.title
        filename = section.file ? Pathname.new(section.file).sub_ext('.dita').relative_path_from(base_dir) : file
        current  = last_level

        next if filename == last_file

        while current > level
          current -= 1
          result << '  ' * (current + offset) + %(</topicref>)
        end

        indent  = '  ' * (level + offset)
        parent  = (sections[i + 1] and sections[i + 1].level > level) ? true : false
        result << indent + %(<topicref href="#{filename}" navtitle="#{title}"#{parent ? '>' : ' />'}) unless filename == $stdin

        last_level = level
        last_file  = filename
      end

      while last_level > 0
        last_level -= 1
        break if last_level == 0 and file == $stdin
        result << '  ' * (last_level + offset) + %(</topicref>)
      end

      if @opts[:standalone]
        result << %(</map>)
      end

      if output == $stdout
        $stdout.write result.join("\n")
      else
        File.write output, result.join("\n")
      end
    end

    def convert_topic file, input, output
      if file == $stdin
        base_dir = Pathname.new(Dir.pwd).expand_path
      else
        base_dir = Pathname.new(file).dirname.expand_path
      end

      Asciidoctor.convert input, backend: 'dita-topic', standalone: @opts[:standalone], safe: :unsafe, attributes: @attr, to_file: output, base_dir: base_dir
    end

    def run
      prepended = ''

      @prep.each do |file|
        prepended << File.read(file)
        prepended << "\n"
      end

      @args.each do |file|
        if file == $stdin
          input  = $stdin.read
          output = @opts[:output] ? @opts[:output] : $stdout
        else
          suffix = @opts[:map] ? '.ditamap' : '.dita'
          input  = File.read(file)
          output = @opts[:output] ? @opts[:output] : Pathname.new(file).sub_ext(suffix).to_s
        end

        input.gsub!(Asciidoctor::IncludeDirectiveRx, '//\&') unless @opts[:includes]

        if @opts[:map]
          convert_map file, prepended + input, output
        else
          convert_topic file, prepended + input, output
        end
      end
    end
  end
end
