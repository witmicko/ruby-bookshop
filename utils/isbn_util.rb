class ISBN_util
  def self.to_i(isbn)
    Integer(isbn.tr('-', ''))
  end

  def self.to_s(isbn)
    hyphens = [3, 5, 13, 15]

    isbnFormat = isbn.to_s
    hyphens.each do |e|
      if e < isbnFormat.length
        isbnFormat.insert(e, '-')
      else
        break
      end
    end
    isbnFormat
  end
end