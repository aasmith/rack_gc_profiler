$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rack_gc_profiler'

require 'minitest/autorun'

# A GC::Profiler-compatible API that pretends to measure GC work.
class FakeProfiler

  class << self
    def enable
      @enabled = true
    end

    def disable
      @enabled = false
    end

    def clear
      @raw_data = []
      @total_time = 0
    end

    def raw_data
      @raw_data
    end

    def total_time
      @total_time
    end

    def enabled?
      @enabled
    end

    # Updates the profiler to look like it has just measured some GC activity.
    def measure_gc
      return unless enabled?

      @raw_data << { fake: true }
      @total_time += 1.1

    end
  end

  # By default, the profiler is disabled and counters are zeroed.

  disable
  clear

end

class App

  attr_reader :profiler_started

  alias profiler_started? profiler_started

  def call(env)
    @profiler_started = FakeProfiler.enabled?

    if env[:do_gc]
      # do gc the number of times specified, or once if not a number.
      [env[:do_gc].to_i,1].max.times do
        FakeProfiler.measure_gc
      end
    end

    raise "App Error" if env[:raise]

    [200, {}, "body"]
  end

end
