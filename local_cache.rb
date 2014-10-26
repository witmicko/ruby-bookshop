require_relative 'book_in_stock'


class LocalCache
  attr_accessor :locCache

  def initialize
    @data = Hash.new
  end

  def get(key)
    entry = @data[key]
    if entry
      entry[:ttl]-=1
      @data.delete(key) if entry[:ttl] == 0
    end
    entry
  end


  def set(key, value)
    @data.store(key, value)
  end


  def delete_entry(key)
    @data.delete(key)
  end


  def display_cache
    @data.each { |k, v| puts "#{k} - #{v}" }
  end

end