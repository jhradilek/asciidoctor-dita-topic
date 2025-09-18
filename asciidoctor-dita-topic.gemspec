Gem::Specification.new do |s|
  # General information:
  s.name        = 'asciidoctor-dita-topic'
  s.version     = '1.2.2'
  s.summary     = 'A custom AsciiDoc converter that generates individual DITA topics'
  s.description = 'An extension for AsciiDoctor that converts a single AsciiDoc file to a DITA topic.'
  s.authors     = ['Jaromir Hradilek']
  s.email       = 'jhradilek@gmail.com'
  s.files       = ['lib/dita-topic.rb', 'LICENSE', 'AUTHORS', 'README.adoc']
  s.homepage    = 'https://github.com/jhradilek/asciidoctor-dita-topic'
  s.license     = 'MIT'

  # Relevant metadata:
  s.metadata = {
    'homepage_uri'      => 'https://github.com/jhradilek/asciidoctor-dita-topic',
    'bug_tracker_uri'   => 'https://github.com/jhradilek/asciidoctor-dita-topic/issues',
    'documentation_uri' => 'https://github.com/jhradilek/asciidoctor-dita-topic/blob/main/README.adoc'
  }

  # Required gems:
  s.add_runtime_dependency 'asciidoctor', '~> 2.0', '>= 2.0.0'

  # Development gems:
  s.add_development_dependency 'rake', '~> 12.3.0'
  s.add_development_dependency 'minitest', '~> 5.22.0'
  s.add_development_dependency 'rexml', '~> 3.2.6'
end
