require 'digest'

class Document < ActiveRecord::Base
  has_many :transactions

  def scan(base: nil)
    path = base + self.path
    md5 = Digest::MD5.file(path).hexdigest.downcase
    print "Scanning #{self.path} ... "
    if md5 == self.md5
      puts 'skipping (unchanged)'
    else
      reader = Statements::Reader.for_file(path)
      if reader
        Transaction.delete_all document: self if persisted?
        reader.transactions.each do |t|
          t.document = self
          t.save! unless Transaction.find_by('checksum = ? AND document_id != ?', t.checksum!, id || 0)
        end
        puts "added #{transactions.count} transactions(s)"
      else
        puts 'skipping (unknown format)'
      end
    end
    self.md5 = md5
    save!
  end

end
