# Make sure repository has either tag or branch(not both!) named "VERSION.ITERATION"
PUPPET_GIT   = ENV["upstream_puppet_git"] || "git://github.com/Yelp/puppet.git"
VERSION      = "3.7.4"
ITERATION    = "y2"

PACKAGE_NAME = "puppet-omnibus"
BUILD_NUMBER = ENV["upstream_build_number"] || 0
CURDIR       = Dir.pwd
OS_BUILDS    = %w(hardy lucid precise trusty centos5 centos6)

def package_name_suffix(os)
  case os
  when "hardy", "lucid", "precise", "trusty"
    "_#{VERSION}+yelp-#{BUILD_NUMBER}_amd64.deb"
  when /centos/
    "-#{VERSION}.yelp_#{BUILD_NUMBER}-1.x86_64.rpm"
  end
end

def package_name(os)
  "dist/#{os}/#{PACKAGE_NAME}#{package_name_suffix(os)}"
end

def run(cmd)
  puts "+ #{cmd}"
  raise if !ENV['DRY'] && !system(cmd)
end

def fetch_puppet_git(dir)
  run "rm -rf '#{dir}/puppet-git'"
  run "git clone '#{PUPPET_GIT}' '#{dir}/puppet-git'"
end

def with_tempdir
  tempdir = `mktemp -d`.strip
  yield tempdir
ensure
  `rm -rf #{tempdir}`
end

def make_dockerfile(os)
  run "mkdir -p dockerfiles/#{os}"
  run "OS=#{os} ./rocker.rb > dockerfiles/#{os}/Dockerfile"
  `md5sum dockerfiles/#{os}/Dockerfile | cut -c-32`.strip
end

OS_BUILDS.each do |os|
  task :"docker_#{os}" do
    docker_md5 = make_dockerfile os
    raise "Dockerfile md5 is empty, wtf?" if "#{docker_md5}".empty?

    if `docker images | grep package_#{PACKAGE_NAME}_#{os} | grep #{docker_md5}`.strip.empty?
      run "cp -r #{CURDIR}/vendor/* dockerfiles/#{os}/"
      run <<-SHELL
        cd dockerfiles/#{os} && \
        flock /tmp/#{PACKAGE_NAME}_#{os}_docker_build.lock \
          docker build -t "package_#{PACKAGE_NAME}_#{os}:#{docker_md5}" .
      SHELL
    end
  end

  task :"package_#{os}" => :"docker_#{os}" do
    fetch_puppet_git CURDIR
    docker_md5 = make_dockerfile os
    run "[ -d pkg ] || mkdir pkg"
    run "[ -d dist/#{os} ] || mkdir -p dist/#{os}"
    run "chmod 777 pkg dist/#{os}"
    run <<-SHELL
      unbuffer docker run -t -i \
        -e BUILD_NUMBER=#{BUILD_NUMBER} \
        -e PUPPET_VERSION=#{VERSION}.#{ITERATION} \
        -e HOME=/package \
        -u jenkins \
        -v #{CURDIR}:/package_source:ro \
        -v #{CURDIR}/dist/#{os}:/package_dest:rw \
        -v /etc/ssh/ssh_known_hosts:/etc/ssh/ssh_known_hosts:ro \
        "package_#{PACKAGE_NAME}_#{os}:#{docker_md5}" \
        /bin/bash /package_source/JENKINS_BUILD.sh
    SHELL
  end

  task :"itest_#{os}" => :"package_#{os}" do
    run <<-SHELL
      docker run \
        -v #{CURDIR}/itest:/itest:ro -v #{CURDIR}/dist:/dist:ro \
        docker-dev.yelpcorp.com/#{os}_yelp /itest/#{os}.sh /#{package_name(os)}
    SHELL
  end
end

task :clean do
  run "rm -rf dist/ cache/"
  run "rm -f .*docker_is_created"
end

task :all       => OS_BUILDS.map { |os| :"itest_#{os}" }
task :build_all => OS_BUILDS.map { |os| :"package_#{os}" }
