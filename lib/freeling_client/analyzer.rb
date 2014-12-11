require "open3"
require "tempfile"
require "timeout"
require "hashie/mash"
require "freeling_client/base"


module FreelingClient
  class Analyzer < Base

    def initialize(opt={})
      @config = opt.fetch(:config, 'config/freeling/analyzer.cfg')
      @port = opt[:port]
      @server = opt[:server]
      @timeout = opt.fetch(:timeout, 60) # Three hours
    end

    def call(cmd, text)
      valide_command!(cmd)

      output = []
      file = Tempfile.new('foo', encoding: 'utf-8')
      begin
        file.write(text)
        file.close
        stdin, stdout, stderr = Open3.popen3(command(cmd, file.path))
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

    def command(cmd, file_path)
      self.send("command_#{cmd}", file_path)
    end

    def command_morfo(file_path)
      "#{freeling_share} #{freeling_bin} -f #{config} --inpf plain --outf morfo < #{file_path}"
    end

    def command_tagged(file_path)
      "#{freeling_share} #{freeling_bin} -f #{config} --inpf plain --outf tagged < #{file_path}"
    end

    def command_tagged_nec(file_path)
      "#{freeling_share} #{freeling_bin} -f #{config} --inpf plain --outf tagged --nec --noflush < #{file_path}"
    end

    def command_tagged_sense(file_path)
      "#{freeling_share} #{freeling_bin} -f #{config} --inpf plain --outf sense --sense all < #{file_path}"
    end

    def freeling_share
      "FREELINGSHARE=/usr/local/share/freeling/"
    end

    def freeling_bin
      "/usr/local/bin/analyzer"
    end

    def valide_command!(cmd)
      unless [:morfo, :tagged, :tagged_nec, :tagged_sense].include?(cmd)
        raise CommandError, "#{cmd} does not exist"
      end
    end
  end
end
