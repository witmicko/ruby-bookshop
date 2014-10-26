require_relative 'user_command'

class AddNewBookCommand < UserCommand

  def initialize (data_source)
    super (data_source)
    @isbn = ''
    @title = ''
    @price = ''
    @author = ''
    @genre = ''
    @quantity = ''
  end

  def title
    'Add new Book.'
  end

  def input
    puts 'Adding new book:'
    print 'ISBN: '
    @isbn = STDIN.gets.chomp
    print 'Title: '
    @title = STDIN.gets.chomp
    @price = get_price
    print 'Author: '
    @author = STDIN.gets.chomp
    @genre = get_genre
    @quantity = get_quantity
  end


  def execute
    # if @data_source.find_isbn(@isbn).nil?
    book = BookInStock.new(isbn: @isbn,
                           title: @title,
                           author: @author,
                           genre: $GENRE[@genre],
                           price: @price,
                           quantity: @quantity)
    begin
      @data_source.add_book book
    rescue Exception => e
      puts e.message
      puts "oops, isbn: #{book.isbn} already used"
    end
  end

  def get_genre
    puts 'Available genres:'
    $GENRE.each_index { |g| puts "\t #{g + 1}. #{$GENRE[g]}" }
    begin
      print 'Genre: '
      genre = Integer(STDIN.gets.chomp) - 1
      if (0..$GENRE.size) === genre
        genre
      else
        puts 'Choice outside of range, try again'
        get_genre
      end
    rescue
      puts 'Not a number, try again'
      get_genre
    end
  end

  def get_price
    begin
      print 'Price: '
      Float(STDIN.gets.chomp)
    rescue
      puts 'Not a number'
      get_price
    end
  end

  def get_quantity
    begin
      print 'Quantity: '
      @quantity = STDIN.gets.chomp
    rescue
      puts 'Not a number'
      get_quantity
    end
  end

end