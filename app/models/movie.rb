class Movie < ApplicationRecord
    mount_uploader :image_path, ImageUploader
    
    has_many :comments
    has_many :likes
    has_many :users, through: :likes
end
