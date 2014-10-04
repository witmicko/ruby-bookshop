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
    @price = getPrice
    print 'Author: '
    @author = STDIN.gets.chomp
    @genre = getGenre

  end


  def execute
    b = BookInStock.new(@isbn, @title, @author, $GENRE[@genre], @price, @quantity)

  end

  def getGenre
    puts 'Available genres:'
    $GENRE.each_index { |g| puts "\t #{g + 1}. #{$GENRE[g]}" }
    begin
      print 'Genre: '
      genre = Integer(STDIN.gets.chomp) - 1
      puts genre
      if (0..$GENRE.size) === genre
        genre
      else
        puts 'Choice outside of range, try again'
        getGenre
      end
    rescue
      puts 'Not a number, try again'
      getGenre
    end
  end

  def getPrice
    begin
      print 'Price: '
      Float(STDIN.gets.chomp)
    rescue
      puts 'Not a number'
      getPrice
    end
  end

  def getQuantity
    begin
      print 'Quantity: '
      @quantity = STDIN.gets.chomp
    rescue
      puts 'Not a number'
      getQuantity
    end
  end

end