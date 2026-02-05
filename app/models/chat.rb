class Chat < ApplicationRecord
  belongs_to :user
  belongs_to :fashion_answer
  has_many :messages, dependent: :destroy

  validates :title, presence: true
end
