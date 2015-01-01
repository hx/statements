require 'active_record'

class Transaction < ActiveRecord::Base
  belongs_to :account
  belongs_to :document

  def set_account(name, number)
    self.account = Account.find_or_create_by(
        name: name,
        number: number
    )
  end

end
