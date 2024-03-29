require 'sequel'
require 'sqlite3'
require 'logger'
require_relative 'book_in_stock'

class DataBase

  def initialize (db_path)
    @db_path = db_path
    @db_ref = nil
  end

  def start
    @db_ref = Sequel.sqlite(@db_path)
    @db_ref.loggers << Logger.new($stdout)
  end

  def stop
  end

  def find_isbn(isbn)
    dataset = @db_ref[:books].where(:isbn => isbn)
    objects = object_relational_mapper dataset
    if objects
      objects[0]
    end
  end

  def author_search(author)
    # dataset = @DB_ref[:books].where(:author => author)
    dataset = @db_ref[:books].where(Sequel.ilike(:author, author.downcase))
    object_relational_mapper dataset
  end

  def add_book(book)
    books = @db_ref[:books]
    books.insert(:isbn => book.isbn,
                 :author => book.author,
                 :genre => book.genre,
                 :title => book.title,
                 :price => book.price,
                 :quantity => book.quantity)
  end

  def update_book(book)
    books = @db_ref[:books].where(:isbn => book.isbn)
    books.update(:author => book.author,
                 :genre => book.genre,
                 :title => book.title,
                 :price => book.price,
                 :quantity => book.quantity)
  end

  def delete_book(isbn)
    @db_ref[:books].where(:isbn => isbn).delete
  end

  def genre_search(genre)
    dataset = @db_ref[:books].where(:genre => genre)
    object_relational_mapper dataset
  end

  private
  def object_relational_mapper(dataset)
    books = []
    dataset.each do |d|
      books << BookInStock.new(isbn: d[:isbn],
                               title: d[:title],
                               author: d[:author],
                               genre: d[:genre],
                               price: d[:price],
                               quantity: d[:quantity])
    end
    books
  end

end 

