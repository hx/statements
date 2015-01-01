require 'digest'

class Document < ActiveRecord::Base
  has_many :transactions

  def scan(base: nil)
    path = base + self.path
    md5 = Digest::MD5.file(path).hexdigest.downcase
    unless md5 == self.md5
      reader = Statements::Reader.for_file(path)
      if reader
        Transaction.delete_all document: self if persisted?
        reader.transactions.each do |t|
          t.document = self
          t.save!
        end
      end
    end
    self.md5 = md5
    save!
  end

end
