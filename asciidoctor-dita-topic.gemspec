Gem::Specification.new do |s|
  # General information:
  s.name        = 'asciidoctor-dita-topic'
  s.version     = '1.0.0'
  s.summary     = 'A custom AsciiDoc converter that generates individual DITA topics'
  s.description = 'An extension for AsciiDoctor that converts a single AsciiDoc file to a DITA topic.'
  s.authors     = ['Jaromir Hradilek']
  s.email       = 'jhradilek@gmail.com'
  s.files       = ['lib/dita-topic.rb']
  s.homepage    = 'https://github.com/jhradilek/asciidoctor-dita-topic/'
  s.license     = 'MIT'

  # Required gems:
  s.add_runtime_dependency 'asciidoctor', '~> 2.0', '>=2.0.0'
end
