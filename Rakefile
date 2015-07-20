require 'bundler/gem_tasks'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.options = [
      '--markup', 'markdown',
      '-o', 'doc/',
      '--private'
    ]
  end
rescue LoadError
end

begin
  require 'stackprof'
  desc 'profile the benchmark task'
  task :prof do
    stackprof_data = StackProf.run(mode: :wall, out: 'stackprof.out') do
      Rake::Task["bench"].execute
    end
  end
rescue LoadError
end

begin
  require 'benchmark'
  desc 'benchmark YaleSparseMatrix against Matrix'
  task :bench do
    require 'sparsematrix/yale'
    require 'matrix'

    SIZES = [
      [10, 10],
      [100, 100],
      # [1000, 1000],
      # [10_000, 10_000]
    ]
    DENSITIES = [0.1, 0.3, 0.5, 0.7, 0.9]
    N = 100
    SIZES.each do |rows, cols|
      printf "Size: %d rows x %d cols\n", rows, cols
      space_efficient_density_threshold = (rows * (cols - 1) - 1) / (2.0 * rows * cols)
      printf "Expect density threshold: %.2f", space_efficient_density_threshold
      DENSITIES.each do |density|
        zero = 0
        puts
        printf "Density: %.2f\n", density
        puts "YaleSparseMatrix"
        Benchmark.bm(16) do |bm|
          sparse = nil
          bm.report("initialize") do
            N.times do
              sparse = SparseMatrix::YaleSparseMatrix.build(zero, rows, cols) { rand <= density ? 1 : zero }
            end
          end
          bm.report("iterate all") do
            N.times do
              sparse.each(true) { |e| e == 1 }
            end
          end
          bm.report("iterate non zero") do
            N.times do
              sparse.each { |e| e == 1 }
            end
          end
        end

        puts
        puts "Matrix"
        Benchmark.bm(16) do |bm|
          matrix = nil
          bm.report("initialize") do
            N.times do
              matrix = Matrix.build(rows, cols) { rand <= density ? 1 : zero }
            end
          end
          bm.report("iterate all") do
            N.times do
              matrix.each { |e| e == 1 }
            end
          end
          bm.report("iterate non zero") do
            N.times do
              matrix.each.select{ |e| e!= zero }.each { |e| e == 1 }
            end
          end
        end

        puts
      end
    end
  end
rescue LoadError
end
