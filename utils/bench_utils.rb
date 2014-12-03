require 'open4'
require 'colorize'

class CommandRunException < Exception
end

class BenchUtils

  def self.run_command cmd
    puts 'Running command: ' + "'#{cmd}'".green
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

  def self.benchmark_games
    `ls benchmark-game/benchmarks/*.rb`.split(/\n/).collect {|benchmark| benchmark.strip.sub(/^[a-zA-Z\-]+\//, '') }
  end

end