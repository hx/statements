require 'active_record'

class Transaction < ActiveRecord::Base
  belongs_to :account
  belongs_to :document
end
