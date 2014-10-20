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
      entry[:ttl]+=1
      @data.delete[isbn] if entry[:ttl] >= @ttl
    end
    entry
  end


  def set(isbn, version, book)
    @data.store(isbn, {version: version,
                       book: book,
                       ttl: 1})
  end

  def deleteEntry(isbn)
    @data.delete(isbn)
  end

end