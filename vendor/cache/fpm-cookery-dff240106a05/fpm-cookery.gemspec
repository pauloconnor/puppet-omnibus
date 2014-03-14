# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "fpm-cookery"
  s.version = "0.16.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Bernd Ahlers"]
  s.date = "2014-03-14"
  s.description = "A tool for building software packages with fpm."
  s.email = ["bernd@tuneafish.de"]
  s.executables = ["fpm-cook"]
  s.files = [".autotest", ".gitignore", ".travis.yml", "CHANGELOG.md", "Gemfile", "LICENSE", "README.md", "Rakefile", "bin/fpm-cook", "fpm-cookery.gemspec", "lib/fpm/cookery/book.rb", "lib/fpm/cookery/book_hook.rb", "lib/fpm/cookery/chain_packager.rb", "lib/fpm/cookery/cli.rb", "lib/fpm/cookery/config.rb", "lib/fpm/cookery/dependency_inspector.rb", "lib/fpm/cookery/exceptions.rb", "lib/fpm/cookery/facts.rb", "lib/fpm/cookery/log.rb", "lib/fpm/cookery/log/color.rb", "lib/fpm/cookery/log/output/console.rb", "lib/fpm/cookery/log/output/console_color.rb", "lib/fpm/cookery/log/output/null.rb", "lib/fpm/cookery/omnibus_packager.rb", "lib/fpm/cookery/package/dir.rb", "lib/fpm/cookery/package/gem.rb", "lib/fpm/cookery/package/maintainer.rb", "lib/fpm/cookery/package/package.rb", "lib/fpm/cookery/package/version.rb", "lib/fpm/cookery/packager.rb", "lib/fpm/cookery/path.rb", "lib/fpm/cookery/path_helper.rb", "lib/fpm/cookery/recipe.rb", "lib/fpm/cookery/shellout.rb", "lib/fpm/cookery/source.rb", "lib/fpm/cookery/source_handler.rb", "lib/fpm/cookery/source_handler/curl.rb", "lib/fpm/cookery/source_handler/git.rb", "lib/fpm/cookery/source_handler/hg.rb", "lib/fpm/cookery/source_handler/local_path.rb", "lib/fpm/cookery/source_handler/noop.rb", "lib/fpm/cookery/source_handler/svn.rb", "lib/fpm/cookery/source_handler/template.rb", "lib/fpm/cookery/source_integrity_check.rb", "lib/fpm/cookery/utils.rb", "lib/fpm/cookery/version.rb", "recipes/arr-pm/recipe.rb", "recipes/backports/recipe.rb", "recipes/cabin/recipe.rb", "recipes/clamp/recipe.rb", "recipes/facter/recipe.rb", "recipes/fpm-cookery-gem/addressable.rb", "recipes/fpm-cookery-gem/arr-pm.rb", "recipes/fpm-cookery-gem/backports.rb", "recipes/fpm-cookery-gem/cabin.rb", "recipes/fpm-cookery-gem/childprocess.rb", "recipes/fpm-cookery-gem/clamp.rb", "recipes/fpm-cookery-gem/facter.rb", "recipes/fpm-cookery-gem/ffi.rb", "recipes/fpm-cookery-gem/fpm.rb", "recipes/fpm-cookery-gem/ftw.rb", "recipes/fpm-cookery-gem/hiera.rb", "recipes/fpm-cookery-gem/http_parser.rb.rb", "recipes/fpm-cookery-gem/json.rb", "recipes/fpm-cookery-gem/json_pure.rb", "recipes/fpm-cookery-gem/puppet.rb", "recipes/fpm-cookery-gem/recipe.rb", "recipes/fpm-cookery-gem/rgen.rb", "recipes/fpm-cookery/fpm-cook.bin", "recipes/fpm-cookery/recipe.rb", "recipes/fpm-cookery/ruby.rb", "recipes/fpm/recipe.rb", "recipes/json/recipe.rb", "recipes/nodejs/recipe.rb", "recipes/omnibustest/bundler-gem.rb", "recipes/omnibustest/recipe.rb", "recipes/omnibustest/ruby.rb", "recipes/open4/recipe.rb", "recipes/redis/recipe.rb", "recipes/redis/redis-server.init.d", "spec/config_spec.rb", "spec/facts_spec.rb", "spec/fixtures/test-config-1.yml", "spec/fixtures/test-source-1.0.tar.gz", "spec/package_maintainer_spec.rb", "spec/package_spec.rb", "spec/package_version_spec.rb", "spec/path_helper_spec.rb", "spec/path_spec.rb", "spec/recipe_spec.rb", "spec/source_integrity_check_spec.rb", "spec/source_spec.rb", "spec/spec_helper.rb"]
  s.homepage = ""
  s.require_paths = ["lib"]
  s.rubyforge_project = "fpm-cookery"
  s.rubygems_version = "1.8.25"
  s.summary = "A tool for building software packages with fpm."
  s.test_files = ["spec/config_spec.rb", "spec/facts_spec.rb", "spec/fixtures/test-config-1.yml", "spec/fixtures/test-source-1.0.tar.gz", "spec/package_maintainer_spec.rb", "spec/package_spec.rb", "spec/package_version_spec.rb", "spec/path_helper_spec.rb", "spec/path_spec.rb", "spec/recipe_spec.rb", "spec/source_integrity_check_spec.rb", "spec/source_spec.rb", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<minitest>, ["~> 5.0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_runtime_dependency(%q<fpm>, ["~> 0.4"])
      s.add_runtime_dependency(%q<facter>, [">= 0"])
      s.add_runtime_dependency(%q<puppet>, [">= 0"])
      s.add_runtime_dependency(%q<addressable>, [">= 0"])
      s.add_runtime_dependency(%q<systemu>, [">= 0"])
    else
      s.add_dependency(%q<minitest>, ["~> 5.0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<fpm>, ["~> 0.4"])
      s.add_dependency(%q<facter>, [">= 0"])
      s.add_dependency(%q<puppet>, [">= 0"])
      s.add_dependency(%q<addressable>, [">= 0"])
      s.add_dependency(%q<systemu>, [">= 0"])
    end
  else
    s.add_dependency(%q<minitest>, ["~> 5.0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<fpm>, ["~> 0.4"])
    s.add_dependency(%q<facter>, [">= 0"])
    s.add_dependency(%q<puppet>, [">= 0"])
    s.add_dependency(%q<addressable>, [">= 0"])
    s.add_dependency(%q<systemu>, [">= 0"])
  end
end
