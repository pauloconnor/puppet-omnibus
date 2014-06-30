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
  "dist/#{os}/#{PACKAGE_NAME}_#{VERSION}+yelp-#{BUILD_NUMBER}#{package_name_suffix(os)}"
end

def run(cmd)
  puts "+ #{cmd}"
  raise if !ENV['DRY'] && !system(cmd)
end

def with_tempdir
  tempdir = `mktemp -d`.strip
  yield tempdir
ensure
  `rm -rf #{tempdir}`
end

OS_BUILDS.each do |os|
  task :"docker_#{os}" do
    run "mkdir -p dockerfiles/#{os}"
    run "OS=#{os} ./rocker.rb > dockerfiles/#{os}/Dockerfile"

    current_docker_md5 = `md5sum dockerfiles/#{os}/Dockerfile`.strip
    last_docker_md5    = File.read(".#{os}_docker_is_created").strip rescue nil

    raise "Dockerfile md5 is empty, wtf?" if "#{current_docker_md5}".empty?

    puts "last Dockerfile md5: #{last_docker_md5}"
    puts "current Dockerfile md5: #{current_docker_md5}"

    if current_docker_md5 != last_docker_md5
      with_tempdir do |tempdir|
        run "cp -r #{CURDIR}/vendor/* dockerfiles/#{os}/"
        run <<-SHELL
          flock /tmp/#{PACKAGE_NAME}_#{os}_docker_build.lock \
            docker build -t "package_#{PACKAGE_NAME}_#{os}" dockerfiles/#{os}/ && \
          echo "#{current_docker_md5}" > .#{os}_docker_is_created
        SHELL
      end
    end
  end

  task :"package_#{os}" => :"docker_#{os}" do
    with_tempdir do
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
