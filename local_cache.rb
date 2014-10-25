require_relative 'book_in_stock'
require_relative 'utils/isbn_util'


class LocalCache
  attr_accessor :locCache

  def initialize(args = {})
    @data = Hash.new()
    @ttl = args[:ttl]
  end

  def get(isbn)
    if (entry = @data[isbn])
      entry[:ttl]-=1
      @data.delete(isbn) if entry[:ttl] == 0
    end
    entry
  end


  def set(isbn, version, book)
    @data.store(isbn, {version: version,
                       book: book,
                       ttl: @ttl})
  end

  def deleteEntry(isbn)
    @data.delete(isbn)
  end


  def display_cache
    @data.each { |k, v| puts "#{k} - #{v}" }
  end

end