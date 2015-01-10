class Account < ActiveRecord::Base
  def self.as_json(options = nil)
    order('name asc').map &:as_json
  end

  def as_json(options = nil)
    slice :id, :name, :number
  end
end
