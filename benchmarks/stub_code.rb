require 'pathname'

def stub_code
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

$bench_folder = ARGV.shift
$bench_runnable = ARGV.shift
$bench_code = File.read(Pathname.new(File.expand_path(File.dirname(__FILE__))).join($bench_folder, $bench_runnable))

stub_code

File.open(Pathname.new(File.expand_path(File.dirname(__FILE__))).join($bench_folder, "benchstub_#{$bench_runnable}"), 'w') do |f|
  f.write($bench_code)
end