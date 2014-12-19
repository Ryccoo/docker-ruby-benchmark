require 'open3'

def rvm_versions
  `rvm list`.split(/\n/).reject {|version| version =~ /^rvm rubies/ || version =~ /^\s*$/}.collect {|version| version.match(/\s*([^\s]*)/)[1].strip }
end

def run_benchmarks(bench = nil)
  benchs = bench ? [bench] : benchmarks
  1.times do # Temporary just run them once
    benchs.each do |benchmark|
      next unless benchmark_needs_run?(benchmark)
      puts "time -p ruby #{benchmark} #{benchmark_args(benchmark)}"

      if ENV['RUBY_VERSION'] =~ /jruby/
        # jruby does not work well with capture3, so lets hack it other way
        stdout_str = `bash -lc 'time -p ruby #{benchmark} #{benchmark_args(benchmark)}' 2>/tmp/stderr`
        stderr_str = File.read('/tmp/stderr')
        write_result(benchmark, stderr_str, stdout_str)
      else
        # other implementations should go along with this
        stdout_str, stderr_str, status = Open3.capture3("bash -lc 'time -p ruby #{benchmark} #{benchmark_args(benchmark)}'")
        puts stderr_str if status.exitstatus > 0
        write_result(benchmark, stderr_str, stdout_str) if status.exitstatus == 0
      end
    end
  end
end

def benchmark_args(benchmark)
  basename = benchmark.gsub(/\.rb/, '')
  if File.exists?("#{basename}.arg")
    File.open("#{basename}.arg", 'r') {|f| f.read }.strip
  elsif File.exists?("#{basename}.input")
    "< #{basename}.input"
  end
end

def benchmark_needs_run?(benchmark)
  `cat /tmp/results.csv | grep #{benchmark} | wc -l`.to_i < 7
end

def write_result(benchmark, stats, stdout_str)
  puts stats
  stdout_str = stdout_str.ascii_only? ? stdout_str : ' '
  stdout_str = stdout_str[0...100].gsub("\n", ' ')
  times = stats.split(/\n/).take(20).map{|t| t[0...50] }
  time = times.find {|t| t =~ /real/ }
  time = time ? time.gsub(/real\s*/, '') : nil
  File.open('/tmp/results.csv', 'a') do |f|
    f.puts "#{ARGV[0]};#{benchmark};#{time};#{Time.now.to_s};#{times};#{stdout_str}; "
  end
end

def benchmarks
  `ls benchmarks/*.rb`.split(/\n/).collect {|benchmark| benchmark.strip }
end

run_benchmarks(ARGV[1])