class ISBN_util
  def self.to_i(isbn)
    Integer(isbn.tr('-', ''))
  end
end