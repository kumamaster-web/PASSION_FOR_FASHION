class AddGenderToFashionAnswers < ActiveRecord::Migration[7.1]
  def change
    add_column :fashion_answers, :gender, :string
  end
end
