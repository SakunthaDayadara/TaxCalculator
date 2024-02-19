class CreateTaxes < ActiveRecord::Migration[7.0]
  def change
    create_table :taxes do |t|
      t.decimal :grossincome
      t.decimal :taxdeduction
      t.decimal :epfdeduction
      t.decimal :employerepfcontribution
      t.decimal :netincome

      t.timestamps
    end
  end
end
