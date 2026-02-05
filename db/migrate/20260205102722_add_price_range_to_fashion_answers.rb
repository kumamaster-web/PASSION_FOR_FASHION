class AddPriceRangeToFashionAnswers < ActiveRecord::Migration[7.1]
  def change
    add_column :fashion_answers, :price_min, :integer
    add_column :fashion_answers, :price_max, :integer
    add_column :fashion_answers, :currency, :string
  end
end
