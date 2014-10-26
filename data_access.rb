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
    @local_cache = LocalCache.new()
    @loc_cache_ttl = 5
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
        @local_cache.set(isbn_sym, {version: in_shared[:version], book: book, ttl: @loc_cache_ttl})
      else
        isbn_str = isbn_sym.to_s
        book = @database.find_isbn(isbn_str)
        if book
          @remote_cache.set(isbn_sym, {version: 1, book: book.to_cache})
          @local_cache.set(isbn_sym, {version: 1, book: book, ttl: @loc_cache_ttl})
        end
      end
    end
  end

  def author_search(author)
    author_key = "bks_#{author}".to_sym
    in_shared = @remote_cache.get(author_key)
    in_local = @local_cache.get_complex(author_key)

    books = []
    if in_local and in_shared and in_shared[:versions] == in_local[:versions]
      display_cache
      books = in_local[:data]
    else
      if in_shared
        books_serialised = in_shared[:data].split(';')
        books_serialised.each { |b| books << BookInStock.from_cache(b) }
        @local_cache.set(author_key,
                         {versions: in_shared[:versions], data: books, ttl: @loc_cache_ttl})
      else
        books = @database.author_search author
        if books.any?
          versions = ''
          author_books = []
          books_serialized = String.new
          books.each do |b|
            isbn = b.isbn
            cache_entry = update_caches(isbn.to_sym)
            author_books << isbn
            books_serialized << "#{cache_entry[:book].to_cache};"
            versions << "#{isbn}_v#{cache_entry[:version]},"

            @remote_cache.set(author_key,
                              {books: author_books, versions: versions, data: books_serialized})
            @local_cache.set(author_key,
                             {books: author_books, versions: versions, data: books,
                              ttl: @loc_cache_ttl})
          end
        end
      end
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
      in_loc =@local_cache.get(isbn)
      if in_loc
        @local_cache.set(isbn, {version: ver, book: book, ttl: in_loc[:ttl]})
        puts
      end
    end
    author_key = "bks_#{book.author}".to_sym
    @remote_cache.delete(author_key)
    @local_cache.delete_entry(author_key)

  end

  def delete_book(isbn)
    book = find_isbn(isbn)

    @database.delete_book(isbn)
    isbn_sym = isbn.to_sym
    @local_cache.delete_entry(isbn_sym)
    @remote_cache.delete(isbn_sym)

    author_key = "bks_#{book.author}".to_sym
    @remote_cache.delete(author_key)
    @local_cache.delete_entry(author_key)
  end

  def add_book(book)
    @database.add_book book

    author_key = "bks_#{book.author}".to_sym
    @remote_cache.delete(author_key)
    @local_cache.delete_entry(author_key)
  end

  def genre_search(genre)
    @database.genre_search genre
  end

  def display_cache
    puts 'Local cache:'
    @local_cache.display_cache
  end


end