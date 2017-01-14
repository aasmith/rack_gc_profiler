require "rack_gc_profiler/version"

module RackGcProfiler
  class Middleware

    GC_TIME_FORMAT = "%0.6f".freeze
    GC_TIME_HEADER = "GC-Time".freeze
    GC_RUNS_HEADER = "GC-Runs".freeze

    attr_reader :profiler

    def initialize(app, profiler = GC::Profiler)
      @app = app
      @profiler = profiler
    end

    def call(env)
      @profiler.enable

      status, headers, body = @app.call(env)

      headers[GC_TIME_HEADER] = GC_TIME_FORMAT % @profiler.total_time
      headers[GC_RUNS_HEADER] = @profiler.raw_data.size.to_s

      [status, headers, body]

    ensure
      @profiler.disable
      @profiler.clear

    end

  end
end
