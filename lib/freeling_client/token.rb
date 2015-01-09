module FreelingClient
  class Token

    attr_accessor :form, :lemma, :tag, :prob, :pos

    def initialize(opt = {})
      @form = opt[:form]
      @lemma = opt[:lemma]
      @tag = opt[:tag]
      @prob = opt[:tag]
    end

    def [](key)
      key = key.to_sym if key.is_a? String
      self.send(key)
    end
  end
end
