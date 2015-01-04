require 'active_record'
require 'digest'

class Transaction < ActiveRecord::Base
  belongs_to :account
  belongs_to :document

  before_save :checksum!

  def set_account(name, number)
    self.account = Account.find_or_create_by(
        name: name,
        number: number
    )
  end

  def checksum!
    self.checksum = calculate_checksum
  end

  private

  def calculate_checksum
    parts = [
        account_id.to_s,
        transacted_at.strftime('%F'),
        posted_at.strftime('%F'),
        description,
        amount.to_s,
        balance.to_s
    ]
    Digest::SHA1.hexdigest parts.join "\0"
  end

end
