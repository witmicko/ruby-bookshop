require_relative 'book_in_stock'
require_relative 'database'
require_relative 'local_cache'
require 'dalli'

class DataAccess

  def initialize(db_path)
    @database = DataBase.new db_path
    @remote_cache = Dalli::Client.new('localhost:11211')
    @remote_cache.flush_all
    # Relevant data structure(s) for local cache
    @local_cache = LocalCache.new({ttl: 5})
  end

  def start
    @database.start
  end

  def stop
  end

  def find_isbn(isbn)
    isbn_sym = isbn.to_sym
    data = update_caches(isbn_sym)
    if data
      data[:book]
    end
  end

  def update_caches(isbn_sym)
    in_local = @local_cache.get(isbn_sym)
    in_shared = @remote_cache.get(isbn_sym)
    if in_local and in_shared and in_shared[:version]==in_local[:version]
      display_cache
      in_local
    else
      if in_shared
        book = in_shared[:book]
        @local_cache.set(isbn_sym, in_shared[:version], book)
      else
        isbn_str = isbn_sym.to_s
        book = @database.find_isbn(isbn_str)
        if book
          @remote_cache.set(isbn_sym, {version: 1, book: book.to_cache})
          @local_cache.set(isbn_sym, 1, book)
        end
      end
    end
  end

  def author_search(author)
    books = nil
    # if author already stored in
    if @remote_cache.get(author)

      # if not, build a complex entity
    else
      books = @database.author_search author
      versions = ''
      author_books = []
      books_serialized = []
      books.each do |b|
        isbn = b.isbn.to_sym
        cache_entry = update_caches(isbn)
        author_books << isbn
        books_serialized << cache_entry[:book].to_cache
        versions  << "#{isbn}_v#{cache_entry[:version]},"
      end
      @remote_cache.set(author.to_sym, {key: versions , data: books_serialized})
      @local_cache.set_complex(author.to_sym, {key: versions , data: books})
      # debug
      # puts "#{author} #{@remote_cache.get(author.to_sym)}"
      # puts @remote_cache.get(author.to_sym)[:key]
      # puts "#{author.to_sym} #{@local_cache.get_complex(author.to_sym)}"


    end
    books
  end

  def update_book(book)
    @database.update_book book
    isbn = book.isbn.to_sym
    in_shared= @remote_cache.get(isbn)
    if in_shared
      ver = in_shared[:version]+1
      @remote_cache.set(isbn, {version: ver, book: book.to_cache})

      if @local_cache.get(isbn)
        @local_cache.set(isbn, ver, book)
      end
    end
  end

  def delete_book(isbn)
    @database.delete_book isbn
    isbn = isbn.to_sym
    @local_cache.delete_entry(isbn)
    @remote_cache.delete(isbn)

  end

  def add_book(book)
    @database.add_book book
  end

  def genre_search(genre)
    @database.genre_search genre
  end

  def display_cache
    puts 'Local cache:'
    @local_cache.display_cache
  end


end