# Freeling::Client

Simple client wrapper for Freeling analyzer tool. If you need to install freeling on Ubuntu 14.04 just follow [this](https://gist.github.com/malev/d6a8b51c2ae0a762ab1d) guide.

## Example of usage:

```ruby
require 'freeling_client'

text <<-EOF
Malcolm X was effectively orphaned early in life. His father was killed when he was six and his mother was placed in a mental hospital when he was thirteen, after which he lived in a series of foster homes.
EOF

options = {
  timeout: 200,
  config: 'config.cfg',
  fidn: 'ident.dat'
}

# Using the language detection tool
lang_detector = FreelingClient::LanguageDetector.new options
lang_detector.detect(text) # => :en

# Morphological, morpho with PoS tagging, tagged words and nec analysis
analyzer = FreelingClient::Analyzer.new options
analyzer.call(:morfo, text)
analyzer.call(:tagged, text)
analyzer.call(:tagged_sense, text)
analyzer.call(:tagged_ned, text)

# Using as a client
# You will need to setup the server first. Check bellow
options = {
  server: 'localhost',
  port: 50005
}

freeling_client = FreelingClient::Client.new options
freeling_client.call(text)
```

## Running Freeling as a server

Performing morphological analysis:

    FREELINGSHARE=/usr/local/share/freeling/ analyzer -f config/freeling/analyzer.cfg --server --port 50005 --inpf plain --outf morfo

Performing morphological with PoS tagging:

    FREELINGSHARE=/usr/local/share/freeling/ analyzer -f config/freeling/analyzer.cfg --server --port 50005 --inpf plain --outf tagged

Asking for the senses of the tagged words:

    FREELINGSHARE=/usr/local/share/freeling/ analyzer -f config/freeling/analyzer.cfg --server --port 50005 --inpf plain --outf sense --sense all

With `nec` analysis:

    FREELINGSHARE=/usr/local/share/freeling/ analyzer -f config/freeling/analyzer.cfg --server --port 50005 --inpf plain --outf tagged --nec --noflush
