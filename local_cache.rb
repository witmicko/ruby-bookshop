require_relative 'book_in_stock'
require_relative 'utils/isbn_util'

class LocalCache
  attr_accessor :locCache

  def initialize
    @data = Hash.new()
  end

  def get(isbn)
    @data[isbn]
  end

  def set(isbn, version, book)
    @data.store(isbn, {version: version, book: book})

  end

  def deleteEntry(isbn)
    @data.delete(isbn)
  end


end