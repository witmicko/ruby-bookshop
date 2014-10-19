require_relative 'book_in_stock'
require_relative 'database'
require_relative 'local_cache'
require 'dalli'

class DataAccess

  def initialize(db_path)
    @database = DataBase.new db_path
    @Remote_cache = Dalli::Client.new('localhost:11211')
    # Relevant data structure(s) for local cache
    @local_cache = LocalCache.new
  end

  def start
    @database.start
  end

  def stop
  end

  def findISBN(isbn)
    if @Remote_cache.fetch(isbn).nil?
      book = @database.findISBN isbn
      @Remote_cache.set(Integer(isbn.tr('-', '')), [1, book])
    end
    book
  end

  def authorSearch(author)
    @database.authorSearch author
  end

  def updateBook(book)
    @database.updateBook book
  end

  def deleteBook(isbn)
    @database.deleteBook isbn
  end

  def addBook(book)
    @local_cache.set book
    @database.addBook book
  end

  def genreSearch(genre)
    @database.genreSearch genre
  end


end