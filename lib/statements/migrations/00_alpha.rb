class Alpha < ActiveRecord::Migration
  def change

    create_table :documents do |t|
      t.string :path
      t.string :md5, limit: 32

      t.timestamps null: true

      t.index :md5, unique: true
    end

    create_table :accounts do |t|
      t.string :name
      t.string :number

      t.timestamps null: true

      t.index [:name, :number], unique: true
    end

    create_table :transactions do |t|
      t.references :document
      t.references :account
      t.integer :document_line
      t.datetime :transacted_at, null: true
      t.datetime :posted_at, null: true
      t.string :description
      t.decimal :amount, precision: 2, scale: 13
      t.decimal :balance, precision: 2, scale: 13
      t.decimal :foreign_amount, precision: 2, scale: 13
      t.string :foreign_currency, limit: 3

      t.string :checksum, limit: 40

      t.timestamps null: true

      t.index :checksum, unique: true
      t.index [:document_id, :document_line], unique: true
    end

  end
end
