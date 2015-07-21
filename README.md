# SparseMatrix

Sparse matrix implementations (just Yale currently) in pure Ruby.

Why? Why not.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sparsematrix'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sparsematrix

## Usage

```ruby
require 'sparsematrix'
sparse = SparseMatrix::YaleSparseMatrix.new 0
(1..10).each { |n| sparse[n, n] = 1 }
sparse.each_with_index { |value, row, column| puts "sparse[#{row}, #{column}] = #{value}" }
# sparse[1, 1] = 1
# sparse[2, 2] = 1
# sparse[3, 3] = 1
# sparse[4, 4] = 1
# sparse[5, 5] = 1
# sparse[6, 6] = 1
# sparse[7, 7] = 1
# sparse[8, 8] = 1
# sparse[9, 9] = 1
# sparse[10, 10] = 1
puts sparse.inspect(true)
# SparseMatrix::YaleSparseMatrix[
# [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
# [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
# [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0],
# [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0],
# [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0],
# [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
# [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0],
# [0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0],
# [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0],
# [0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0],
# [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]] # efficient 8.26% density
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/sparsematrix. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
