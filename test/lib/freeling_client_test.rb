# encoding: utf-8

require 'test_helper'

text = "El gato come pescado. Pero a Don Jaime no le gustan los gatos."

describe FreelingClient do
  it 'detects language' do
    lang_detector = FreelingClient::LanguageDetector.new
    lang_detector.detect(text).must_equal :es
  end

  it 'Uses freeling as a client (mode server)' do
    freeling_client = FreelingClient::Client.new
    freeling_client.call(text)[0].must_equal "El el DA0MS0 1"
  end

  it 'Uses freeling to get a morphological analysis' do
    analyzer = FreelingClient::Analyzer.new
    analyzer.call(:morfo, text)[0].must_equal "El el DA0MS0 1"
  end

  it "returns parsed tokens" do
    analyzer = FreelingClient::Analyzer.new
    analyzer.tokens(:morfo, text).first.lemma.must_equal "el"
  end

  it "returns positionated tokens" do
    analyzer = FreelingClient::Analyzer.new
    tokens = analyzer.ptokens(:morfo, text).to_a
    tokens[0].pos.must_equal 0
    tokens[1].pos.must_equal 3
  end
end
