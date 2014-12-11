require "open3"
require "freeling_client/base"


module FreelingClient
  class LanguageDetector < Base
    def initialize(opt = {})
      @config = opt.fetch(:config, 'config/freeling/analyzer.cfg')
      @ident = opt.fetch(:ident, '/usr/local/share/freeling/common/lang_ident/ident.dat')
      @timeout = opt.fetch(:timeout, 120)
    end

    def detect(text)
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
      output[0].to_sym
    end

    def command(file_path)
      "/usr/local/bin/analyzer --outf ident --fidn #{ident} -f #{config} < #{file_path}"
    end
  end
end
