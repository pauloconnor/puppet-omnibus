PACKAGE_NAME = "puppet-omnibus"
VERSION      = "3.6.2"
BUILD_NUMBER = ENV["upstream_build_number"] || 0
CURDIR       = Dir.pwd
OS_BUILDS    = %w(hardy lucid precise trusty centos5 centos6)

def package_name_suffix(os)
  case os
  when "hardy", "lucy", "precise", "trusty"
    "_amd64.deb"
  when /centos/
    "-1.x86_64.rpm"
  end
end

def package_name(os)
  "dist/#{os}/#{PACKAGE_NAME}_#{VERSION}+yelp-#{BUILD_NUMBER}#{output_package_suffix(os)}"
end

def run(cmd)
  puts "+ #{cmd}"
  system cmd unless ENV['DRY']
end

OS_BUILDS.each do |os|
  task :"docker_#{os}" do
    unless File.exists? ".#{os}_docker_is_created"
      tempdir = `mktemp -d`.strip

      run "mkdir -p dockerfiles/#{os}"
      run "OS=#{os} ./rocker.rb > dockerfiles/#{os}/Dockerfile"
      run "cp -r #{CURDIR}/vendor/* dockerfiles/#{os}/"
      run <<-SHELL
        flock /tmp/#{PACKAGE_NAME}_#{os}_docker_build.lock \
          docker build -t "package_#{PACKAGE_NAME}_#{os}" \
            dockerfiles/#{os}/ && touch .#{os}_docker_is_created
      SHELL
      run "rm -rf #{tempdir} dockerfiles/#{os}/vendor"
    end
  end

  task :"package_#{os}" => :"docker_#{os}" do
    tempdir = `mktemp -d`.strip

    run "[ -d pkg ] || mkdir pkg"
    run "[ -d dist/#{os} ] || mkdir -p dist/#{os}"
    run "chmod 777 pkg dist/#{os} #{tempdir}"
    run <<-SHELL
      unbuffer docker run -t -i \
        -e BUILD_NUMBER=#{BUILD_NUMBER} \
        -e HOME=/package \
        -u jenkins \
        -v #{CURDIR}:/package_source:ro \
        -v #{tempdir}:/tmp:rw -v #{CURDIR}/dist/#{os}/:/package_dest:rw \
        package_#{PACKAGE_NAME}_#{os} /bin/bash /package_source/JENKINS_BUILD.sh
    SHELL
    run "rm -rf #{tempdir}"
  end

  task :"itest_#{os}" => :"package_#{os}" do
    run <<-SHELL
      docker run \
        -v #{CURDIR}/itest:/itest:ro \
        -v #{CURDIR}/dist:/dist:ro \
        docker-dev.yelpcorp.com/#{os}_yelp \
        /itest/#{os}.sh /#{package_name(os)}
    SHELL
  end
end

task :clean do
  run "rm -rf dist/ cache/"
  run "rm -f .*docker_is_created"
end

task :all       => OS_BUILDS.map { |os| :"itest_#{os}" }
task :build_all => OS_BUILDS.map { |os| :"package_#{os}" }
