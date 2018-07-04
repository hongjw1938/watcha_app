class Movie < ApplicationRecord
    mount_uploader :image_path, ImageUploader
    
    
    has_many :likes
end
