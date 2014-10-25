require_relative 'book_in_stock'


class LocalCache
  attr_accessor :locCache

  def initialize(args = {})
    @data = Hash.new
    @ttl = args[:ttl]
  end

  def get(isbn)
    entry = @data[isbn]
    if entry
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

  def delete_entry(isbn)
    @data.delete(isbn)
  end


  def display_cache
    @data.each { |k, v| puts "#{k} - #{v}" }
  end

end