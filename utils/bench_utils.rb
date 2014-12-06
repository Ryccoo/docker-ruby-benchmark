require 'open4'
require 'colorize'
require_relative '../config/config'

class CommandRunException < Exception
end

class BenchUtils

  def self.run_command cmd
    puts 'Running command: ' + "'#{cmd}'".green
    STDOUT.flush
    output = {}
    status = Open4::popen4(cmd) do |pid, stdin, stdout, stderr|
      output[:stdout] = stdout.read.strip
      puts output[:stdout]
      output[:stderr] = stderr.read.strip
    end

    unless status.success?
      puts status.to_s.red
      puts output[:stderr].red
      puts output[:stdout].blue
      raise CommandRunException, "Could not run command '#{cmd}'"
    end

    return output
  end

  def self.spawn_command cmd
    puts 'Spawning command: ' + "'#{cmd}'".green
    pid = spawn cmd
    Process::waitpid(pid)
  end

  def self.benchmark_games
    `ls #{BaseConfig.path.to_s}/benchmark-game/benchmarks/*.rb`.split(/\n/).collect {|benchmark| benchmark.strip.sub(/^[a-zA-Z\-\/]+\//, '') }
  end

end