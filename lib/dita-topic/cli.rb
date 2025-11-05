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
require 'asciidoctor'
require_relative 'version'
require_relative '../dita-topic'

module AsciidoctorDitaTopic
  class Cli
    def initialize name, argv
      @attr = ['experimental']
      @opts = {:output => true, :includes => true, :standalone => true}
      @prep = ''
      @name = name
      @args = self.parse_args argv
    end

    def parse_args argv
      parser = OptionParser.new do |opt|
        opt.banner  = "Usage: #{@name} [OPTION...] FILE...\n"
        opt.banner += "       #{@name} -h|-v\n\n"

        opt.on('-o', '--out-file FILE', 'output file; by default, the output file name is based on the input file') do |output|
          @opts[:output] = (output.strip == '-') ? $stdout : output
        end

        opt.on('-a', '--attribute ATTRIBUTE', 'document attribute to set in the form of name, name!, or name=value pair') do |value|
          @attr.append value
        end

        opt.on('-p', '--prepend-file FILE', 'file to prepend to all input files') do |file|
          raise OptionParser::InvalidArgument, "not a file: #{file}" unless File.exist? file and File.file? file
          raise OptionParser::InvalidArgument, "file not readable: #{file}" unless File.readable? file

          @prep << File.read(file)
          @prep << "\n"
        end

        opt.on('-I', '--no-includes', 'disable processing of include directives') do
          @opts[:includes] = false
        end

        opt.on('-s', '--no-header-footer', 'disable enclosing the content in <topic> and generating <title>') do
          @opts[:standalone] = false
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

    def run
      @args.each do |file|
        if file == $stdin
          input  = $stdin.read
          output = (@opts[:output] == true) ? $stdout : @opts[:output]
        else
          input  = File.read(file)
          output = (@opts[:output] == true) ? Pathname.new(file).sub_ext('.dita').to_s : @opts[:output]
        end

        input.gsub!(Asciidoctor::IncludeDirectiveRx, '//\&') unless @opts[:includes]

        Asciidoctor.convert @prep + input, backend: 'dita-topic', standalone: @opts[:standalone], safe: :unsafe, attributes: @attr, to_file: output
      end
    end
  end
end
