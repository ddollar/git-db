# Generated by jeweler
# DO NOT EDIT THIS FILE
# Instead, edit Jeweler::Tasks in Rakefile, and run `rake gemspec`
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{git-db}
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["David Dollar"]
  s.date = %q{2009-09-14}
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
     "git-db.gemspec",
     "lib/git-db.rb",
     "lib/git-db/commands.rb",
     "lib/git-db/commands/receive-pack.rb",
     "lib/git-db/commands/upload-pack.rb",
     "lib/git-db/database.rb",
     "lib/git-db/objects.rb",
     "lib/git-db/objects/base.rb",
     "lib/git-db/objects/blob.rb",
     "lib/git-db/objects/commit.rb",
     "lib/git-db/objects/entry.rb",
     "lib/git-db/objects/tag.rb",
     "lib/git-db/objects/tree.rb",
     "lib/git-db/pack.rb",
     "lib/git-db/protocol.rb",
     "lib/git-db/utility.rb",
     "lib/git-db/utility/counting_io.rb",
     "spec/git-db/commands_spec.rb",
     "spec/git-db/objects/base_spec.rb",
     "spec/git-db/objects/blob_spec.rb",
     "spec/git-db/objects/commit_spec.rb",
     "spec/git-db/objects/entry_spec.rb",
     "spec/git-db/objects/tag_spec.rb",
     "spec/git-db/objects/tree_spec.rb",
     "spec/git-db/objects_spec.rb",
     "spec/git-db/protocol_spec.rb",
     "spec/git-db/utility/counting_io_spec.rb",
     "spec/git-db_spec.rb",
     "spec/rcov.opts",
     "spec/spec.opts",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/ddollar/git-db}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Database-based git server}
  s.test_files = [
    "spec/git-db/commands_spec.rb",
     "spec/git-db/objects/base_spec.rb",
     "spec/git-db/objects/blob_spec.rb",
     "spec/git-db/objects/commit_spec.rb",
     "spec/git-db/objects/entry_spec.rb",
     "spec/git-db/objects/tag_spec.rb",
     "spec/git-db/objects/tree_spec.rb",
     "spec/git-db/objects_spec.rb",
     "spec/git-db/protocol_spec.rb",
     "spec/git-db/utility/counting_io_spec.rb",
     "spec/git-db_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_runtime_dependency(%q<couchrest>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<couchrest>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<couchrest>, [">= 0"])
  end
end
