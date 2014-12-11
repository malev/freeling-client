require "open3"
require "freeling_client/base"


module FreelingClient
  class Client < Base

    # Initializes the client
    #
    # Example:
    #
    #   >> client = FreelingClient::Client.new
    #
    # Arguments:
    #   server: (String)
    #   port: (String)
    #   timeout: (Integer)
    #
    def initialize(opt = {})
      @server = opt.fetch(:server, 'localhost')
      @port = opt.fetch(:port, 50005)
      @timeout = opt.fetch(:timeout, 120)
    end

    # Calls the server with a given text
    #
    # Example:
    #
    #   >> client = FreelingClient::Client.new
    #   >> client.call("Este texto está en español.")
    #
    # Arguments:
    #   text: (String)
    #
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

    private

    def command(file_path)
      "/usr/local/bin/analyzer_client #{server}:#{port} < #{file_path}"
    end
  end
end
