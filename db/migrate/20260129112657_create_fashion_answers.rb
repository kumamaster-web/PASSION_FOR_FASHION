class CreateFashionAnswers < ActiveRecord::Migration[7.1]
  def change
    create_table :fashion_answers do |t|
      t.references :user, null: false, foreign_key: true
      t.string :image_path
      t.string :lifestyle
      t.string :colors
      t.string :occasion
      t.string :comfort
      t.string :statement
      t.string :personality_type
      t.text :style
      t.text :colour_palette
      t.text :recommended_brands
      t.text :where_to_shop

      t.timestamps
    end
  end
end
