require 'open4'

class CommandRunException < Exception
end

class BenchUtils

  def self.run_command cmd
    output = {}
    status = Open4::popen4(cmd) do |pid, stdin, stdout, stderr|
      output[:stdout] = stdout.read.strip
      output[:stderr] = stderr.read.strip
    end

    unless status.success?
      puts status
      puts output[:stderr]
      raise CommandRunException, "Could not run command '#{cmd}'"
    end

    return output
  end

end