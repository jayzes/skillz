# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{casablanca}
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Petrik de Heus"]
  s.date = %q{2009-02-21}
  s.default_executable = %q{casablanca}
  s.description = %q{Casablanca is a ruby single sign-on client for the CAS 2.0 protocol.}
  s.email = ["FIX@example.com"]
  s.executables = ["casablanca"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "Rakefile", "bin/casablanca", "init.rb", "lib/casablanca.rb", "lib/casablanca/cli.rb", "lib/casablanca/client.rb", "lib/casablanca/rails/cas_proxy_callback_controller.rb", "lib/casablanca/rails/filter.rb", "lib/casablanca/response_parsers.rb", "test/mocks.rb", "test/test_client.rb", "test/test_helper.rb", "test/test_parser.rb", "test/test_rails_cas_proxy_callback_controller.rb", "test/test_rails_filter.rb", "test/test_ticket.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://rubyforge.org/projects/casablanca/}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{casablanca}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Casablanca is a ruby single sign-on client for the CAS 2.0 protocol.}
  s.test_files = ["test/test_client.rb", "test/test_helper.rb", "test/test_parser.rb", "test/test_rails_cas_proxy_callback_controller.rb", "test/test_rails_filter.rb", "test/test_ticket.rb"]

end
