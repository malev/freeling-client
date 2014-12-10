# Freeling Client

Simple client wrapper for Freeling. If you need to install freeling on Ubuntu 14.04 just follow [this](https://gist.github.com/malev/d6a8b51c2ae0a762ab1d) guide.

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

lang_detector = FreelingClient::LanguageDetector.new options
lang_detector.detect(text) # => :en

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


# other stuff

analyze -f myconfig.cfg <mytext.txt >mytext.mrf
analyze -f myconfig.cfg --outf tagged <mytext.txt >mytext.tag
analyze -f myconfig.cfg --outf sense --sense all  <mytext.txt >mytext.sen
analyze -f myconfig.cfg --inpf morfo --outf tagged <mytext.mrf >mytext.tag
analyze --outf ident --fidn /usr/local/share/freeling/common/lang_ident/ident.dat <mytext.txt


analyze -f myconfig.cfg --inpf morfo --outf tagged <mytext.mrf >mytext.tag

