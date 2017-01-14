require 'benchmark'

def busywork
  GC.disable
  100_000.times do |i|
    Object.new

    if i % 10_000 == 0
      GC.enable
      GC.start
      GC.disable
    end
  end
  GC.enable
end

def busywork_with_profiling
  GC::Profiler.enable
  busywork
  GC::Profiler.disable
  GC::Profiler.clear
end

N = 1_000

Benchmark.bmbm do |bm|
  bm.report 'GC Profile' do
    N.times do
      busywork_with_profiling
    end
  end

  bm.report 'No Profile' do
    N.times do
      busywork
    end
  end

end
