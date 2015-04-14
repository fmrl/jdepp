# the jaunty dependency preprocessor

this is a small utility that scans source files for dependency declarations. currently, it only supports [f*](http://fstar-lang.org).

## installation

add this line to your application's Gemfile:

```ruby
gem "jdepp", :git => "https://github.com/fmrl/jdepp.git"
```

and then execute:

    $ bundle

or install it yourself as:

    $ gem install jdepp

## usage

comprehensive documentation doesn't yet exist but for usage information, you can type `jdepp` without any options.

## contributing

1. fork it ( https://github.com/fmrl/jdepp/fork )
2. create your feature branch (`git checkout -b my-new-feature`)
3. commit your changes (`git commit -am 'Add some feature'`)
4. push to the branch (`git push origin my-new-feature`)
5. create a new Pull Request
