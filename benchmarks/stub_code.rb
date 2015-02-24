require 'pathname'

def stub_code_exit
  code = ""
  if defined? $bench_code.lines
    $bench_code.lines.each do |l|
      if l.index('exit') && l.index('#') && l.index('#') < l.index('exit')
        code << l
      else
        code << l.gsub(/exit\s?\(?[0-9]*\)?/, "raise BenchExitException\n")
      end
    end
  else
    $bench_code.split("\n").each do |l|
      if l.index('exit') && l.index('#') && l.index('#') < l.index('exit')
        code << l + "\n"
      else
        l = l.gsub(/exit\s?\(?[0-9]*\)?/, "raise BenchExitException")
        l += "\n"
        code << l
      end
    end
  end
  $bench_code = code
end

def wrap_code
  code = ""
  inserted = false
  code << <<-END
require 'benchmark'

class BenchExitException < Exception
end

bench_mem_start = `ps -o rss= -p \#{$$}`.to_i
bench_result = Benchmark.measure do
  begin
  END
  $bench_code.split("\n").each do |l|
    if l =~ /__END__/
      inserted = true
      code << <<-END
  rescue BenchExitException => e
  end
end
GC.start
bench_mem_total = `ps -o rss= -p \#{$$}`.to_i
bench_mem_used = bench_mem_total - bench_mem_start
$stderr.puts "real \#{bench_result.real}"
$stderr.puts "memory \#{bench_mem_used}"
$stderr.puts "memory_total \#{(bench_mem_total / 1024.0)}"
  END
    end

    code << l
    code << "\n"
  end

  unless inserted
    code << <<-END
  rescue BenchExitException => e
  end
end
GC.start
bench_mem_total = `ps -o rss= -p \#{$$}`.to_i
bench_mem_used = bench_mem_total - bench_mem_start
$stderr.puts "real \#{bench_result.real}"
$stderr.puts "memory \#{bench_mem_used}"
$stderr.puts "memory_total \#{(bench_mem_total / 1024.0)}"
    END
  end

  $bench_code = code
end

$bench_folder = ARGV.shift
$bench_runnable = ARGV.shift
$bench_code = File.read(Pathname.new(File.expand_path(File.dirname(__FILE__))).join($bench_folder, $bench_runnable))

stub_code_exit
wrap_code

File.open(Pathname.new(File.expand_path(File.dirname(__FILE__))).join($bench_folder, "benchstub_#{$bench_runnable}"), 'w') do |f|
  f.write($bench_code)
end