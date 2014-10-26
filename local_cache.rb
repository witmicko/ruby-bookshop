require_relative 'book_in_stock'


class LocalCache
  attr_accessor :locCache

  def initialize
    @data = Hash.new
  end

  def get(isbn)
    entry = @data[isbn]
    if entry
      entry[:ttl]-=1
      @data.delete(isbn) if entry[:ttl] == 0
    end
    entry
  end


  def set(isbn, key)
    @data.store(isbn, key)
  end

  def set_complex(key, value)
    @data.store(key, value)
  end

  def get_complex(key)
    @data[key]
  end

  def delete_entry(key)
    @data.delete(key)
  end


  def display_cache
    @data.each { |k, v| puts "#{k} - #{v}" }
  end

end