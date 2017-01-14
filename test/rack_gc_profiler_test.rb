require 'test_helper'

class RackGcProfilerTest < Minitest::Test
  def setup
    @app = App.new
    @middleware = RackGcProfiler::Middleware.new(@app, FakeProfiler)
  end

  def test_middleware_uses_assigned_profiler
    assert_equal FakeProfiler, @middleware.profiler
  end

  def test_middleware_defaults_to_system_profiler
    middleware = RackGcProfiler::Middleware.new(@app)

    assert_equal GC::Profiler, middleware.profiler
  end

  def test_middleware_logs_no_gc_activity
    status, headers, body = @middleware.call({})

    assert_equal ["GC-Runs", "0"], headers.assoc("GC-Runs")
    assert_equal ["GC-Time", "0.000000"], headers.assoc("GC-Time")
  end

  def test_middleware_logs_gc_activity
    status, headers, body = @middleware.call({do_gc: 1})

    assert_equal ["GC-Runs", "1"], headers.assoc("GC-Runs")
    assert_equal ["GC-Time", "1.100000"], headers.assoc("GC-Time")
  end

  def test_middleware_logs_multiple_gc_activities
    status, headers, body = @middleware.call({do_gc: 2})

    assert_equal ["GC-Runs", "2"], headers.assoc("GC-Runs")
    assert_equal ["GC-Time", "2.200000"], headers.assoc("GC-Time")
  end

  def test_middleware_starts_and_stops_profiler
    @middleware.call({})

    assert @app.profiler_started

    refute FakeProfiler.enabled?
    assert_empty FakeProfiler.raw_data
    assert_equal 0, FakeProfiler.total_time
  end

  def test_middleware_starts_and_stops_profiler_after_app_error
    assert_raises do
      @middleware.call({raise: true})
    end

    assert @app.profiler_started

    refute FakeProfiler.enabled?
    assert_empty FakeProfiler.raw_data
    assert_equal 0, FakeProfiler.total_time
  end

end
