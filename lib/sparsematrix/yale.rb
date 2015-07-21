module SparseMatrix
  # The Yale sparse matrix format stores an initial sparse `m` x `n` matrix, `M`, in
  # row form using three (one-dimensional) arrays (`A`, `IA`, `JA`). Let `NNZ` denote
  # the number of nonzero entries in `M`. (Note that zero-based indices shall be
  # used here.)
  #
  # * The array `A` is of length `NNZ` and holds all the nonzero entries of `M` in
  #   left-to-right top-to-bottom ("row-major") order.
  #
  # * The array `IA` is of length `m + 1` and contains the index in `A` of the first
  #   element in each row, followed by the total number of nonzero elements `NNZ`.
  #   `IA[i]` contains the index in `A` of the first nonzero element of row `i`. Row `i`
  #   of the original matrix extends from `A[IA[i]]` to `A[IA[i + 1] - 1]`, i.e.
  #   from the start of one row to the last index before the start of the next.
  #   The last entry, `IA[m]`, must be the number of elements in `A`.
  #
  # * The third array, `JA`, contains the column index in `M` of each element of `A`
  #   and hence is of length `NNZ` as well.
  #
  # For example, the matrix
  #
  #     0 0 0 0
  #     5 8 0 0
  #     0 0 3 0
  #     0 6 0 0
  #
  # is a 4 x 4 matrix with 4 nonzero elements, hence
  #
  #     A  = [ 5 8 3 6 ]
  #     IA = [ 0 0 2 3 4 ]
  #     JA = [ 0 1 2 1 ]
  #
  # So, in array `JA`, the element "5" from `A` has column index 0, "8" and "6"
  # have index 1, and element "3" has index 2.
  #
  # In this case the Yale representation contains 13 entries, compared to 16 in
  # the original matrix. The Yale format saves on memory only when
  # `NNZ < (m (n - 1) - 1) / 2`. Another example, the matrix
  #
  #     10 20  0  0  0  0
  #      0 30  0 40  0  0
  #      0  0 50 60 70  0
  #      0  0  0  0  0 80
  #
  # is a 4 x 6 matrix (24 entries) with 8 nonzero elements, so
  #
  #     A  = [ 10 20 30 40 50 60 70 80 ]
  #     IA = [ 0 2 4 7 8 ]
  #     JA = [ 0 1 1 3 2 3 4 5 ]
  #
  # The whole is stored as 21 entries.
  #
  # `IA` splits the array `A` into rows: `(10, 20) (30, 40) (50, 60, 70) (80)`;
  # `JA` aligns values in columns:
  # `(10, 20, ...) (0, 30, 0, 40, ...)(0, 0, 50, 60, 70, 0) (0, 0, 0, 0, 0, 80)`.
  # Note that in this format, the first value of `IA` is always zero and the last
  # is always `NNZ`, so they are in some sense redundant. However, they can make
  # accessing and traversing the array easier for the programmer.
  #
  # https://en.wikipedia.org/wiki/Sparse_matrix#Yale
  class YaleSparseMatrix
    def self.build(zero, rows, columns, &block)
      return enum_for :build, rows, columns unless block_given?
      smx = new zero
      rows.times do |row|
        columns.times do |column|
          value = yield row, column
          smx[row, column] = value unless value == zero
        end
      end
      smx
    end

    # @param zero The value to return for zero / unused elements
    def initialize(zero = nil)
      @zero = zero
      @elements = []
      @row_index = [0]
      @index_column = []
    end
    attr_reader :zero, :elements, :row_index,
                :index_column

    alias_method :a, :elements
    alias_method :ia, :row_index
    alias_method :ja, :index_column

    # @param row [Numeric] row part of the index to return
    # @param column [Numeric] column part of the index to return
    # @return the element at the given index, or #zero
    def [](row, column)
      index = element_index row, column
      return zero unless index
      elements[index]
    end
    alias_method :element, :[]
    alias_method :component, :[]

    # @param row [Numeric] row part of the index to set
    # @param column [Numeric] column part of the index to set
    # @param value the value to set
    # @return the value that was passed in
    def []=(row, column, value)
      row_count_l = row_count
      if row >= row_count_l
        add_rows(row - row_count_l + 1)
        row_count_l = row_count
      end
      row_start, row_end = row_index[row], row_index[row + 1]
      index = row_start
      current_column = nil
      while index < row_end
        if index_column[index] >= column
          current_column = column
          break
        end
        index += 1
      end
      index = nil unless current_column

      if index.nil?
        @elements.insert(row_end, value)
        @index_column.insert(row_end, column)
        while row < row_count_l
          row += 1
          @row_index[row] += 1
        end
      else
        if column == current_column
          # replacing an element
          @elements[index] = value
        else
          @elements.insert(index, value)
          @index_column.insert(index, value)
          while row < row_count_l
            row += 1
            @row_index[row] += 1
          end
        end
      end
      value
    end

    # Compares two SparseMatrix's for equality
    # @param other [YaleSparseMatrix]
    # @return [Boolean]
    def ==(other)
      return false unless other.is_a? YaleSparseMatrix
      nonzero_element_count == other.nonzero_element_count &&
        elements == other.elements &&
        row_index == other.row_index &&
        index_column == other.index_column
    end

    # @param block
    # @return [YaleSparseMatrix] a new SparseMatrix whos elements have been mapped
    #                        through the supplied block
    def collect(&block)
      return enum_for :collect unless block_given?
      clone.instance_eval { @elements.collect(&block) }
    end
    alias_method :map, :collect

    # @return [Numeric] The number of columns in the matrix
    def column_count
      row_index
      index_column.last + 1
    end
    alias_method :n, :column_count

    # @return the density of the SparseMatrix; that is, how many elements are
    #         non-zero divided by the total size of the matrix
    def density
      nonzero_element_count / (row_count * column_count * 1.0)
    end
    alias_method :sparsity, :density

    # Passes each element of the matrix to the supplied block
    # @param block
    # @return [YaleSparseMatrix]
    def each(zeroes = false, &block)
      return enum_for :each, zeroes unless block_given?
      if zeroes
        row_count.times do |row|
          column_count.times do |col|
            yield self[row, col]
          end
        end
      else
        @elements.each(&block)
      end
      self
    end

    # Passes each element of the matrix and its index to the supplied block
    # @param block
    # @return [YaleSparseMatrix]
    def each_with_index(zeroes = false, &_block)
      return enum_for :each_with_index, zeroes unless block_given?
      if zeroes
        row_count.times do |row|
          column_count.times do |_col|
            element = self[row, column]
            yield [element, row, column]
          end
        end
      else
        ia.each_cons(2).each_with_index do |indexes, row|
          a[indexes.first...indexes.last].each_with_index do |element, index|
            yield [element, row, ja[index]]
          end
        end
      end
    end

    # Returns true if the matrix is empty; i.e. if {nonzero_element_count} is 0
    # @return [Boolean]
    def empty?
      nonzero_element_count == 0
    end
    alias_method :zero?, :empty?

    # Returns true if the matrix includes element
    # @param element
    # @return [Boolean]
    def include?(element)
      @elements.include? element
    end

    # Returns the index of element in the matrix, or nil
    # @param element
    # @return [Array(Numeric, Numeric), nil]
    def index(element)
      each_with_index { |e, index| return index if e == element }
      nil
    end

    def inspect(zeroes = false)
      "#{self.class}[\n" +
        row_count.times.map do |row|
          column_count.times.map { |col| self[row, col] }
            .reject { |e| !zeroes && e == zero }.inspect
        end.join(",\n") +
        '] # ' \
        "#{saving_memory? ? 'efficient' : 'not efficient'} " \
        "#{format '%.02f', density * 100.0}% density"
    end

    # The number of non-zero elements in the matrix
    # @return [Numeric]
    def nonzero_element_count
      @row_index.last
    end
    alias_method :nnz, :nonzero_element_count

    # The number of rows in the matrix
    # @return [Numeric]
    def row_count
      row_index.length - 1
    end
    alias_method :m, :row_count

    # Returns true if the SparseMatrix uses less memory than a naive matrix
    # @return [Boolean]
    def saving_memory?
      nnz < (m * (n - 1) - 1) / 2
    end

    private

    # Extends #{@row_index}
    # @param count [Numeric] the number of rows to add
    def add_row(count = 1)
      @row_index += [row_index.last] * count
    end
    alias_method :add_rows, :add_row

    # Calculates the index in {@elements} of the given matrix index. Returns nil
    # if the index is outside the matrix's bounds.
    # @param row [Numeric]
    # @param column [Numeric]
    # @return [Numeric, nil]
    def element_index(row, column)
      index = row_index_min = row_index[row]
      row_index_max = row_index[row + 1]
      return nil unless row_index_min && row_index_max
      return nil if row_index_min == row_index_max
      while index < row_index_max
        current_column = index_column[index]
        return index if current_column == column
        if current_column > column
          return nil
        end
        index += 1
      end
    end

    # Sets the number of non-zero elements. For reasons, this is stored as the
    # last element in {@row_index}.
    # @param nnz [Numeric]
    def nonzero_element_count=(nnz)
      @row_index[-1] = nnz
    end
  end
end
