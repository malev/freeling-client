module FreelingClient
  class Base
    attr_reader :config, :ident, :server, :port

    class ExtractionError < StandardError; end
    class CommandError < StandardError; end

  end
end
