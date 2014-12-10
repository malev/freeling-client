require 'test_helper'


describe FreelingClient do
  it 'detects language' do
    text = "El gato come pescado. Pero a Don Jaime no le gustan los gatos."
    lang_detector = FreelingClient::LanguageDetector.new
    lang_detector.detect(text).must_equal :es
  end

  it 'Uses freeling as a client (mode server)' do
    text = "El gato come pescado. Pero a Don Jaime no le gustan los gatos."
    freeling_client = FreelingClient::Client.new
    freeling_client.call(text)[0].must_equal "El el DA0MS0 1"
  end
end
