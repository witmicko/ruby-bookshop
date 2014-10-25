require_relative 'user_command'

class AuthorSearchCommand < UserCommand

  def initialize (data_source)
    super (data_source)
    @author = ''
  end

  def title
    'Search by author.'
  end

  def input
    puts 'Search by Author.'
    print 'Author mame? '
    @author = STDIN.gets.chomp
  end

  def execute
    books = @data_source.author_search(@author)
    books.each { |b| puts b } unless books.nil?
  end

end