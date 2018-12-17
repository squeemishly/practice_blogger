users = []
articles = []

10.times do
  user = User.create(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    username: Faker::Cat.unique.name,
    email: Faker::Internet.unique.email,
    password: Faker::Pokemon.name
  )

  users << user

  puts "#{user.username} has been created with password #{user.password}!"
end

20.times do
  user = users.sample

  article = Article.new(
    title: Faker::FamousLastWords.unique.last_words,
    body: Faker::ChuckNorris.unique.fact,
    user: user
  )

  articles << article

  puts "#{article.title} was created by #{user.username}!"
end

20.times do
  user = users.sample

  article = Article.new(
    title: Faker::StarWars.unique.quote,
    body: Faker::ChuckNorris.unique.fact,
    user: user
  )

  articles << article

  puts "#{article.title} was created by #{user.username}!"
end

20.times do
  user = users.sample

  article = Article.new(
    title: Faker::WorldOfWarcraft.unique.quote,
    body: Faker::PrincessBride.unique.quote,
    user: user
  )

  articles << article

  puts "#{article.title} was created by #{user.username}!"
end

50.times do
  user = users.sample
  article = articles.sample

  comment = Comment.new(
    body: Faker::Hacker.unique.say_something_smart,
    user: user,
    article: article
  )

  puts "#{user.username} said something smart about #{article.title}"
end
