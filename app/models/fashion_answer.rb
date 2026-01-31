class FashionAnswer < ApplicationRecord
  belongs_to :user

  has_one_attached :generated_image
end
