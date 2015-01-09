# encoding: utf-8

require "enumerator"
require "open3"
require "tempfile"
require "timeout"

require "freeling_client/base"


module FreelingClient
  class Analyzer < Base
    def initialize(opt={})
      @config = opt.fetch(:config, 'config/freeling/analyzer.cfg')
      @timeout = opt.fetch(:timeout, 60) # Three hours
    end

    # Generate tokens for a given text
    #
    # Example:
    #
    #   >> analyzer = FreelingClient::Analyzer.new
    #   >> analyzer.token(:morfo, "Este texto está en español.")
    #
    # Arguments:
    #   cmd: (Symbol)
    #   text: (String)
    #
    def tokens(cmd, text)
      valide_command!(cmd)
      Enumerator.new do |yielder|
        call(cmd, text).each do |freeling_line|
          yielder << parse_token_line(freeling_line) unless freeling_line.empty?
        end
      end
    end

    # Generate ptokens for a given text
    # ptokens: Tokens with position
    #
    # Example:
    #
    #   >> analyzer = FreelingClient::Analyzer.new
    #   >> analyzer.ptoken(:morfo, "Este texto está en español.")
    #
    # Arguments:
    #   cmd: (Symbol)
    #   text: (String)
    #
    def ptokens(cmd, text)
      Enumerator.new do |yielder|
        pos = 0
        tokens(cmd, text).each do |token|
          ne_text = token['form'].dup

          ne_regexp = build_regexp(ne_text)
          token_pos = text.index(ne_regexp, pos)

          if token_pos && token_pos < (pos + 5)
            token.pos = token_pos
            yielder << token

            pos = token_pos + ne_text.length
          else
            pos = pos + ne_text.length
          end
        end
      end
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

    def parse_token_line(str)
      form, lemma, tag, prob = str.split(' ')[0..3]
      FreelingClient::Token.new({
        :form => form,
        :lemma => lemma,
        :tag => tag,
        :prob => prob.nil? ? nil : prob.to_f,
      }.reject { |k, v| v.nil? })
    end

    def build_regexp(ne_text)
      begin
        if ne_text =~ /\_/
           /#{ne_text.split('_').join('\W+')}/i
        else
          /#{ne_text}/i
        end
      rescue RegexpError => e
        /./
      end
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
