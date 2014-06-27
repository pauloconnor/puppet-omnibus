#!/usr/bin/env ruby

class Rocker
  def initialize(file)
    @file = file
    @data = File.read file
  end

  DOCKER_DIRECTIVES=%w{from run volume add}
  DOCKER_DIRECTIVES.each do |dir|
    define_method(dir) { |content| puts "#{dir.upcase} #{content}" }
  end

  # special case:
  # strip lines in single run block and join them together
  def run(command)
    puts "RUN " << command.lines.to_a.map(&:strip).reject{|s| s==''}.join("; ")
  end

  def method_missing(method, *args)
    case method.to_s
    when /^env_(\w+)/
      ENV[$1.upcase]
    else
      puts method
    end
  end

  def dockerfile
    instance_eval @data, @file
  end
end

Rocker.new(ARGV[0]).dockerfile
