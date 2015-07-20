require 'matrix'
require 'spec_helper'

describe SparseMatrix do
  it 'has a version number' do
    expect(SparseMatrix::VERSION).not_to be nil
  end
end

describe SparseMatrix::YaleSparseMatrix do
  it 'behaves as documented - example 1' do
    m = SparseMatrix::YaleSparseMatrix.new 0
    expect(m.row_count).to eq 0
    m[1, 0] = 5
    m[1, 1] = 8
    m[2, 2] = 3
    m[3, 1] = 6

    expect(m.elements).to eq [5, 8, 3, 6]
    expect(m.row_index).to eq [0, 0, 2, 3, 4]
    expect(m.index_column).to eq [0, 1, 2, 1]
    expect(m.nonzero_element_count).to eq 4

    expect(m[1, 0]).to eq 5
    expect(m[1, 1]).to eq 8
    expect(m[2, 2]).to eq 3
    expect(m[3, 1]).to eq 6

    expect(m[0, 0]).to eq 0
    expect(m[0, 1]).to eq 0
    expect(m[0, 2]).to eq 0
    expect(m[0, 3]).to eq 0
    expect(m[1, 2]).to eq 0
    expect(m[2, 1]).to eq 0
    expect(m[2, 3]).to eq 0
    expect(m[3, 0]).to eq 0
    expect(m[3, 2]).to eq 0
    expect(m[4, 0]).to eq 0
    expect(m[99, 99]).to eq 0
  end

  it 'behaves as documented - example 2' do
    m2 = SparseMatrix::YaleSparseMatrix.new 0
    m2[0, 0] = 10
    m2[0, 1] = 20
    m2[1, 1] = 30
    m2[1, 3] = 40
    m2[2, 2] = 50
    m2[2, 3] = 60
    m2[2, 4] = 70
    m2[3, 5] = 80

    expect(m2.elements).to eq [10, 20, 30, 40, 50, 60, 70, 80]
    expect(m2.row_index).to eq [0, 2, 4, 7, 8]
    expect(m2.index_column).to eq [0, 1, 1, 3, 2, 3, 4, 5]
    expect(m2.nonzero_element_count).to eq 8

    expect(m2[0, 0]).to eq 10
    expect(m2[0, 1]).to eq 20
    expect(m2[1, 1]).to eq 30
    expect(m2[1, 3]).to eq 40
    expect(m2[2, 2]).to eq 50
    expect(m2[2, 3]).to eq 60
    expect(m2[2, 4]).to eq 70
    expect(m2[3, 5]).to eq 80

    expect(m2[0, 2]).to eq 0
    expect(m2[1, 0]).to eq 0
    expect(m2[1, 2]).to eq 0
    expect(m2[1, 4]).to eq 0
    expect(m2[2, 0]).to eq 0
    expect(m2[2, 1]).to eq 0
    expect(m2[2, 5]).to eq 0
    expect(m2[3, 0]).to eq 0
    expect(m2[3, 6]).to eq 0
    expect(m2[4, 0]).to eq 0
    expect(m2[99, 99]).to eq 0
  end

  it 'uses less spase than a dense Matrix' do
    width = 2**10
    height = 2**10
    element_count = 2**10
    zero = nil

    elements = element_count.times.map do
      row = rand(height)
      col = rand(width)
      [[row, col], rand]
    end.to_h

    mx = Matrix.build(height, width) do |row, col|
      index = [row, col]
      elements[index]
    end

    puts "Matrix size: #{mx.row_count * mx.column_count}"

    sm = SparseMatrix::YaleSparseMatrix.new
    elements.each do |index, value|
      row, col = *index
      sm[row, col] = value
    end

    puts "SparseMatrix size: #{[sm.a, sm.ia, sm.ja].map(&:length).reduce(&:+)}"

    expect(sm.saving_memory?).to be true
  end

  it 'can represent the empty matrix' do
    empty = SparseMatrix::YaleSparseMatrix.new

    expect(empty.empty?).to eq true
    (0...100).to_a.repeated_combination(2) do |row, col|
      expect(empty[row, col]).to eq nil
    end
    expect(empty.empty?).to eq true
  end

  it 'can be modified' do
    m = SparseMatrix::YaleSparseMatrix.new

    10.times do |row|
      10.times do |col|
        m[row, col] = 1
      end
    end
    expect(m[0, 0]).to eq 1

    m[0, 0] = 1
    expect(m[0, 0]).to eq 1

    m[0, 0] = 2
    expect(m[0, 0]).to eq 2

    100.times do
      row = rand(10)
      col = rand(10)
      value = rand(100)
      m[row, col] = value
      expect(m[row, col]).to eq value
    end
  end

  it 'can be compared for equality' do
    m1 = SparseMatrix::YaleSparseMatrix.new 0
    m2 = SparseMatrix::YaleSparseMatrix.new 0

    100.times do
      row = rand(2**10)
      col = rand(2**10)
      value = rand(2**10)

      m1[row, col] = value
      m2[row, col] = value
    end

    expect(m1.elements).to eq m2.elements
    expect(m1.row_index).to eq m2.row_index
    expect(m1.index_column).to eq m2.index_column
    expect(m1.nonzero_element_count).to eq m2.nonzero_element_count

    expect(m1).to eq m2
  end
end
