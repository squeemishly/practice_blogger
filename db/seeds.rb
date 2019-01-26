users = []
articles = []
photos = [
  "boomer.jpg",
  "buffy.jpg",
  "captain-georgiou.jpg",
  "cindy_mayweather.png",
  "michael-burnham.jpg",
  "Rain-Ocampo.jpg",
  "shuri.jpg",
  "wonder-woman.jpg",
  "xena.jpg",
  "zoe.jpg"
]

pic = photos.sample

admin = User.create(
  first_name: "Admin",
  last_name: "McAdminy",
  username: "AdminMcAdminy",
  email: "AdminMcAdminy@admin.com",
  password: "Password1!",
  role: "admin"
)

admin.avatar.attach(io: File.open("app/assets/images/#{pic}"), filename: pic)
puts "admin avatar attached?: #{admin.avatar.attached?}"

10.times do
  pic = photos.sample
  user = User.create!(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    username: Faker::Cat.unique.name,
    email: Faker::Internet.unique.email,
    password: "Password1!"
  )

  user.avatar.attach(io: File.open("app/assets/images/#{pic}"), filename: pic)
  puts "user avatar attached?: #{user.avatar.attached?}"

  users << user

  puts "#{user.username} has been created with image #{pic}!"
end

20.times do
  user = users.sample

  article = Article.create(
    title: Faker::WorldOfWarcraft.unique.quote,
    body: Faker::PrincessBride.unique.quote,
    user: user
  )

  articles << article

  puts "#{article.title} was created by #{user.username}!"
end

20.times do
  user = users.sample

  article = Article.create(
    title: Faker::FamousLastWords.unique.last_words,
    body: Faker::ChuckNorris.unique.fact,
    user: user
  )

  articles << article

  puts "#{article.title} was created by #{user.username}!"
end

20.times do
  user = users.sample

  article = Article.create(
    title: Faker::StarWars.unique.quote,
    body: Faker::ChuckNorris.unique.fact,
    user: user
  )

  articles << article

  puts "#{article.title} was created by #{user.username}!"
end

100.times do
  user = users.sample
  article = articles.sample

  comment = Comment.create(
    body: Faker::Hacker.unique.say_something_smart,
    user: user,
    article: article
  )

  puts "#{user.username} said something smart about #{article.title}"
end
