class AddPersonaToFashionAnswers < ActiveRecord::Migration[7.1]
  def change
    add_column :fashion_answers, :persona, :string
  end
end
