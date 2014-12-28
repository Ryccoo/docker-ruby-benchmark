require 'pathname'
require 'benchmark'

class BenchExitException < Exception
end

def run_code
  eval $bench_code
rescue BenchExitException
end

$bench_folder = ARGV.shift
$bench_runnable = ARGV.shift
$bench_run_times = 1

if ARGV[0] && ARGV[0] =~ /\.input\Z/
  $bench_input_path = Pathname.new(File.expand_path(File.dirname(__FILE__))).join($bench_folder, ARGV[0])
  $bench_stdin = Object.send(:remove_const, :STDIN)
  $bench_stub_stdin = true
end

$bench_code = File.read(Pathname.new(File.expand_path(File.dirname(__FILE__))).join($bench_folder, "benchstub_#{$bench_runnable}"))

if File.exist?(Pathname.new(File.expand_path(File.dirname(__FILE__))).join($bench_folder, "benchstub_#{$bench_runnable}"))
  File.delete(Pathname.new(File.expand_path(File.dirname(__FILE__))).join($bench_folder, "benchstub_#{$bench_runnable}"))
end

$bench_run_times.times do
  if $bench_stub_stdin
    Object.send(:remove_const, :STDIN) if defined?(STDIN)
    STDIN = File.open($bench_input_path)
    $stdin = STDIN
  end

  result = Benchmark.measure do
    run_code
  end

  pid, size = `ps ax -o pid,rss | grep -E "^[[:space:]]*#{$$}"`.strip.split.map {|i| i.to_i }
  $bench_results = {
    :real => result.real, # in sec
    :memory => (size / 1024.0) # in MB
  }

end

$stderr.puts "real #{$bench_results[:real]}"
$stderr.puts "memory #{$bench_results[:memory]}"