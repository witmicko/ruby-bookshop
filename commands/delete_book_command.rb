require_relative 'user_command'

class DeleteBookCommand < UserCommand

  def initialize (data_source)
    super (data_source)
    @isbn = ''
  end

  def title
    'Delete a Book.'
  end

  def input
    puts 'Adding new book:'
    print 'ISBN: '
    @isbn = STDIN.gets.chomp
  end


  def execute
    result = @data_source.findISBN(@isbn)
    if result
      puts "Are you sure you want to delete \n  #{result} ? y/n"
      print 'Response: '
      answer = STDIN.gets.chomp
      if answer.to_s.downcase.include?('y')
        puts "deleting: \n #{result}"
        @data_source.deleteBook @isbn
      end
    else
      puts "Invalid ISBN"
    end
  end

end