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

def docker_run_package
  "unbuffer docker run -t -i -e BUILD_NUMBER=#{BUILD_NUMBER} -v #{CURDIR}:/package_source:ro"
end

def docker_run_itest(os)
  "docker run -v #{CURDIR}/itest:/itest:ro -v #{CURDIR}/dist:/dist:ro docker-dev.yelpcorp.com/#{os}_yelp"
end

def run(cmd)
  puts "+ #{cmd}"
  system cmd
end

OS_BUILDS.each do |os|
  task :"docker_#{os}" do
    tempdir = `mktemp -d`.strip

    run <<-SHELL
      cd dockerfiles/#{os};
      flock /tmp/#{PACKAGE_NAME}_#{os}_docker_build.lock \
        docker build -t \
          "package_#{PACKAGE_NAME}_#{os}" \
          -v #{tempdir}:/tmp:rw
          #{tempdir}:/tmp:rw .;
      touch .#{os}_docker_is_created;
      rm -rf #{tempdir}
    SHELL
  end

  task :"package_#{os}" => :"docker_#{os}" do
    tempdir = `mktemp -d`.strip

    run <<-SHELL
      [ -d pkg ] || mkdir pkg;
      [ -d dist/#{os} ] || mkdir -p dist/#{os};
      chmod 777 pkg dist/#{os} #{tempdir};
      #{docker_run_package} \
        -u jenkins \
        -e HOME=/package \
        -v #{tempdir}:/tmp:rw \
        -v #{CURDIR}/dist/#{os}/:/package_dest:rw \
        package_#{PACKAGE_NAME}_#{os} /bin/bash /package_source/JENKINS_BUILD.sh;
      rm -rf #{tempdir}
    SHELL
  end

  task :"itest_#{os}" => :"package_#{os}" do
    run "#{docker_run_itest(os)} /itest/#{os}.sh /#{package_name(os)}"
  end
end

task :clean do
  run "rm -rf dist/ cache/; rm -f .*docker_is_created"
end

task :all       => OS_BUILDS.map { |os| :"itest_#{os}" }
task :build_all => OS_BUILDS.map { |os| :"package_#{os}" }
