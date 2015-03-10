require 'open4'
require 'colorize'
require_relative '../config/config'

class CommandRunException < Exception
end

class BenchUtils

  def self.run_command cmd
    puts 'Running command: ' + "'#{cmd}'".green if ENV['VERBOSE']
    STDOUT.flush
    output = {}
    status = Open4::popen4(cmd) do |pid, stdin, stdout, stderr|
      output[:stdout] = stdout.read.strip
      puts output[:stdout] if ENV['VERBOSE']
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
    puts 'Spawning command: ' + "'#{cmd}'".green if ENV['VERBOSE']
    pid = spawn cmd
    Process::waitpid(pid)
  end

  def self.benchmarks
    res = {}

    if ENV['BENCH_FILE']
      if File.exist?(BaseConfig.path.join('benchmarks', ENV["BENCH_FILE"]))
        f, r = ENV['BENCH_FILE'].split("/", 2)
        res[f] = [r]
        return res
      else
        $stderr.puts("File #{ENV['BENCH_FILE']} not found")
        exit 1
      end
    end

    self.benchmark_folders.each do |folder|
      items = `ls #{BaseConfig.path.to_s}/benchmarks/#{folder}/*.rb`.split(/\n/).collect {|benchmark| benchmark.strip.sub(/^[a-zA-Z\-\/]+\//, '') }
      items = items.delete_if {|i| i =~ /\Abenchstub_/ }
      res[folder] = items
    end

    res
  end

  def self.benchmark_folders
    dirs = []
    Dir.glob('benchmarks/*').select {|f| File.directory? f}.map{|i| i.slice!('benchmarks/'); dirs << i }
    dirs.delete('custom') # dont automatically run benchmarks in this folder.
    dirs
  end

end