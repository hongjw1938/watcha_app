# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
genres = ["Horror", "Thriller", "Action", "Comedy", "Romance", "SF", "Adventure"]

images = %w[
    https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSYhcUP0q4P1JtKl6OJ8a3XZBiFFlTvAgxxaYpacgwKoJsegAQ8
    https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTusgeEiQ0JYlM4_5LBHs4dbhtE6zzxAMVyFwBgQkVeVFuvLNffgw
    https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRdyYtUbf44CH1jfBcJFRqBsp2yvshZ10LtVoN-ey9DOFB-ZuTt
    https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS_eYjb96YQeNmpjzZ4QZv9w_RY4FOB6oHLZU1VBngL5AJptQfckg
    https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTB5tqXGKJP3Gb8VZtwTnBowVvr9wyrzDC_Bg4tgd35TLS224Vv
]

User.create(email: "aaaa@aaa.aa", password: "123456", password_confirmation: "123456")

30.times do
Movie.create(title: Faker::Movie.quote, genre: genres.sample, director:Faker::Friends.character,
             actors: Faker::FunnyName.two_word_name, remote_image_path_url: images.sample,
             description: Faker::Lorem.paragraph, user_id: 1)

end