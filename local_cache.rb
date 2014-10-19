require_relative 'book_in_stock'
require_relative 'utils/isbn_util'

class LocalCache
  attr_accessor :locCache

  def initialize
    @data = Hash.new([0, BookInStock.new(isbn: '000-0-0000000-0-0',
                                         title: 'default title',
                                         author: 'default author',
                                         genre: nil,
                                         price: 0.0,
                                         quantity: 0)])
  end

  def get key
    @data[key]
  end

  def set(book)
    isbn = ISBN_util.to_i(book.isbn)
    value = [@data[isbn][0]+1, book]

    @data.store(isbn, value)
    puts @data[isbn]
    puts '==================='
    puts @data[isbn][0]
    puts @data[isbn][1]

  end

end