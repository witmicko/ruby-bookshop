require_relative 'book_in_stock'
require_relative 'utils/isbn_util'


class LocalCache
  attr_accessor :locCache

  def initialize(args = {})
    @data = Hash.new()
    @ttl = args[:ttl]
  end

  def get(isbn)
    @data[isbn]
  end

  def set(isbn, version, serializedBook)
    @data.store(isbn, {version: version,
                       book: serializedBook,
                       spawned: timestampSec})

  end

  def deleteEntry(isbn)
    @data.delete(isbn)
  end

  def cleanExpired
    @data.each do |k,v|
      timeAlive = timestampSec - v[:spawned]
      if(@ttl < timeAlive)
        @data.delete(k)
      end
    end


  end

  def timestampSec
    Time.now.getutc.strftime('%s').to_i
  end


end