require_relative 'book_in_stock'
require_relative 'database'
require_relative 'local_cache'
require 'dalli'

class DataAccess

  def initialize(db_path)
    @database = DataBase.new db_path
    @Remote_cache = Dalli::Client.new('localhost:11211')
    @Remote_cache.flush_all
    # Relevant data structure(s) for local cache
    @local_cache = LocalCache.new
  end

  def start
    @database.start
  end

  def stop
  end

  def findISBN(isbn)
    isbn = ISBN_util.to_i(isbn)
    updateCaches(isbn)[:book]
  end

  def updateCaches(isbn)
    inLocal = @local_cache.get(isbn)
    inShared = @Remote_cache.get(isbn)

    if inShared
      if inLocal && inShared[:version]==inLocal[:version]
        inLocal
      else
        book = inShared[:book]
        @local_cache.set(isbn, inShared[:version], book)
      end
    else
      book = @database.findISBN(ISBN_util.to_s(isbn))
      if book
        @Remote_cache.set(isbn, {version: 1, book: book})
        puts @Remote_cache.get(isbn)
        @local_cache.set(isbn, 1, book)
      end
    end

  end

  def authorSearch(author)
    books = @database.authorSearch author
    key = author
    books.sort!{|a,b| a.isbn <=>b.isbn}
    books.each do |b|
      isbn = ISBN_util.to_i(b.isbn)
      cacheEntry = updateCaches(isbn)
      key << "_#{isbn}_v#{cacheEntry[:version]}"

      end
    puts
    books
  end

  def updateBook(book)
    @database.updateBook book
    isbn = ISBN_util.to_i(book.isbn)
    inShared = @Remote_cache.get(isbn)
    if inShared
      ver = inShared[:version]+1
      @Remote_cache.set(isbn, {version: ver, book: book})
    end
    inLoc = @local_cache.get(isbn)
    if inLoc
      @local_cache.set(isbn, ver, book)
    end

  end

  def deleteBook(isbn)
    @database.deleteBook ISBN_util.to_s(isbn)
    isbn = ISBN_util.to_i(isbn)
    @local_cache.deleteEntry(isbn)
    @Remote_cache.delete(isbn)

  end

  def addBook(book)
    @database.addBook book
  end

  def genreSearch(genre)
    @database.genreSearch genre
  end


end