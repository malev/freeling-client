require "open3"
require "freeling_client/base"


module FreelingClient
  class Client < Base
    def initialize(opt = {})
      @server = opt.fetch(:server, 'localhost')
      @port = opt.fetch(:port, 50005)
      @timeout = opt.fetch(:timeout, 120)
    end

    def call(text)
      output = []
      file = Tempfile.new('foo', encoding: 'utf-8')

      begin
        file.write(text)
        file.close
        stdin, stdout, stderr = Open3.popen3(command(file.path))

        Timeout::timeout(@timeout) {
          until (line = stdout.gets).nil?
            output << line.chomp
          end

          message = stderr.readlines
          unless message.empty?
            raise ExtractionError, message.join("\n")
          end
        }
      rescue Timeout::Error
        raise ExtractionError, "Timeout"
      ensure
        file.close
        file.unlink
      end
      output
    end

    def command(file_path)
      "/usr/local/bin/analyzer_client #{server}:#{port} < #{file_path}"
    end
  end
end
