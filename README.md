# RackGcProfiler

A rack middleware for measuring GC activity during a request.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rack_gc_profiler'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack_gc_profiler

## Usage

Install the middleware into your application's list of rack middlewares.

Issue a request to your application where GC will occur. Two extra headers will
be appended to the response:

```console
$ curl -v -o /dev/null -sSq yourapp.example.com
< HTTP/1.1 200 OK
   :
< GC-Runs: 1
< GC-Time: 0.040000
  :
{ [1219 bytes data]
* Connection #0 to host yourapp.example.com left intact
```

`GC-Runs` is the number of times garbage collection ran during the request.
`GC-Time` is the duration of all the GC runs that occured, in seconds.

### Production Usage

Should you use this in production? Profiling anything always adds overhead. To
measure this more concretely, a benchmark has been provided. See benchmark.rb in
the root of the repo. On my machine, using MRI 2.3.1, GC profiling added 0.6%
overhead. This equates to about 0.1ms on a 200ms request. Always evaluate in
your own production environment first and decide for yourself before adding this
to a production application.

To prevent information leakage, the reverse proxy upstream from your
application server should log and delete the two headers listed in the section
above.

### Rails

To install in rails, add the following to your `application.rb`:

```ruby
config.middleware.use RackGcProfiler
```

See http://guides.rubyonrails.org/rails_on_rack.html#configuring-middleware-stack
for more details.

### Sinatra

To install in sinatra, add the following to your application:

```ruby
use RackGcProfiler
```

See http://www.sinatrarb.com/intro#Rack%20Middleware for more details.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aasmith/rack_gc_profiler.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
