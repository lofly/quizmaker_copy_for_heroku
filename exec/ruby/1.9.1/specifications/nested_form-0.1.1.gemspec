# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{nested_form}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.4") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Ryan Bates}, %q{Andrea Singh}]
  s.date = %q{2011-04-23}
  s.description = %q{Gem to conveniently handle multiple models in a single form with Rails 3 and jQuery or Prototype.}
  s.email = %q{ryan@railscasts.com}
  s.homepage = %q{http://github.com/ryanb/nested_form}
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{nested_form}
  s.rubygems_version = %q{1.8.5}
  s.summary = %q{Gem to conveniently handle multiple models in a single form.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, ["~> 2.1.0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
      s.add_development_dependency(%q<rails>, ["~> 3.0.0"])
    else
      s.add_dependency(%q<rspec>, ["~> 2.1.0"])
      s.add_dependency(%q<mocha>, [">= 0"])
      s.add_dependency(%q<rails>, ["~> 3.0.0"])
    end
  else
    s.add_dependency(%q<rspec>, ["~> 2.1.0"])
    s.add_dependency(%q<mocha>, [">= 0"])
    s.add_dependency(%q<rails>, ["~> 3.0.0"])
  end
end
