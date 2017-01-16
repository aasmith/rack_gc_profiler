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
    _, headers, _ = @middleware.call({})

    assert_equal ["GC-Runs", "0"], headers.assoc("GC-Runs")
    assert_equal ["GC-Time", "0.000000"], headers.assoc("GC-Time")
  end

  def test_middleware_logs_gc_activity
    _, headers, _ = @middleware.call({do_gc: 1})

    assert_equal ["GC-Runs", "1"], headers.assoc("GC-Runs")
    assert_equal ["GC-Time", "1.100000"], headers.assoc("GC-Time")
  end

  def test_middleware_logs_multiple_gc_activities
    _, headers, _ = @middleware.call({do_gc: 2})

    assert_equal ["GC-Runs", "2"], headers.assoc("GC-Runs")
    assert_equal ["GC-Time", "2.200000"], headers.assoc("GC-Time")
  end

  def test_middleware_starts_and_stops_profiler
    @middleware.call({})

    assert_profiler_was_started_and_stopped
  end

  def test_middleware_starts_and_stops_profiler_after_app_error
    assert_raises do
      @middleware.call({raise: true})
    end

    assert_profiler_was_started_and_stopped
  end

  def assert_profiler_was_started_and_stopped
    assert @app.profiler_started, "Profiler should be started before app call"
    refute FakeProfiler.enabled?, "Profiler should be stopped after app call"
    assert_empty FakeProfiler.raw_data, "Profiler should be empty"
    assert_equal 0, FakeProfiler.total_time, "Profiler should be empty"
  end
end
