users = []
articles = []
photos = [
  "black-widow.jpg",
  "boomer.jpg",
  "buffy.jpg",
  "captain-georgiou.jpg",
  "cindy_mayweather.png",
  "michael-burnham.jpg",
  "Rain-Ocampo.jpg",
  "shuri.jpg",
  "valkyrie.jpg",
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

users << admin

admin.avatar.attach(io: File.open("app/assets/images/#{pic}"), filename: pic)
puts "admin avatar attached?: #{admin.avatar.attached?}"

20.times do
  pic = photos.sample
  name = Faker::FunnyName.unique.two_word_name.split(" ")
  user = User.create!(
    first_name: name.first,
    last_name: name.last,
    username: Faker::Pokemon.unique.name,
    email: Faker::Internet.unique.email,
    password: "Password1!"
  )

  user.avatar.attach(io: File.open("app/assets/images/#{pic}"), filename: pic)
  puts "user avatar attached?: #{user.avatar.attached?}"

  users << user

  puts "#{user.username} has been created with image #{pic}!"
end

25.times do
  user = users.sample

  article = Article.create(
    title: Faker::WorldOfWarcraft.unique.quote,
    body: Faker::PrincessBride.unique.quote,
    user: user
  )

  articles << article

  puts "#{article.title} was created by #{user.username}!"
end

25.times do
  user = users.sample

  article = Article.create(
    title: Faker::Hipster.sentence(2),
    body: Faker::ChuckNorris.unique.fact,
    user: user
  )

  articles << article

  puts "#{article.title} was created by #{user.username}!"
end

25.times do
  user = users.sample

  article = Article.create(
    title: Faker::FamousLastWords.unique.last_words,
    body: Faker::ChuckNorris.unique.fact,
    user: user
  )

  articles << article

  puts "#{article.title} was created by #{user.username}!"
end

150.times do
  user = users.sample
  article = articles.sample

  comment = Comment.create(
    body: Faker::Hacker.unique.say_something_smart,
    user: user,
    article: article
  )

  puts "#{user.username} said something smart about #{article.title}"
end
