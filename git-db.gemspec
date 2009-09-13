# Generated by jeweler
# DO NOT EDIT THIS FILE
# Instead, edit Jeweler::Tasks in Rakefile, and run `rake gemspec`
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{git-db}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["David Dollar"]
  s.date = %q{2009-09-13}
  s.default_executable = %q{git-db}
  s.description = %q{Database-based git server}
  s.email = %q{<ddollar@gmail.com>}
  s.executables = ["git-db"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "bin/git-db",
     "features/git-db.feature",
     "features/step_definitions/git-db_steps.rb",
     "features/support/env.rb",
     "git-db.gemspec",
     "lib/git-db.rb",
     "lib/git.rb",
     "lib/git/commands.rb",
     "lib/git/commands/receive-pack.rb",
     "lib/git/commands/upload-pack.rb",
     "lib/git/objects.rb",
     "lib/git/objects/base.rb",
     "lib/git/objects/blob.rb",
     "lib/git/objects/commit.rb",
     "lib/git/objects/entry.rb",
     "lib/git/objects/tag.rb",
     "lib/git/objects/tree.rb",
     "lib/git/pack.rb",
     "lib/git/protocol.rb",
     "lib/utility.rb",
     "lib/utility/counting_io.rb",
     "spec/git-db_spec.rb",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/ddollar/git-db}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Database-based git server}
  s.test_files = [
    "spec/git-db_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<yard>, [">= 0"])
      s.add_development_dependency(%q<cucumber>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<yard>, [">= 0"])
      s.add_dependency(%q<cucumber>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<yard>, [">= 0"])
    s.add_dependency(%q<cucumber>, [">= 0"])
  end
end
