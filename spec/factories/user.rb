FactoryBot.define do
  factory :user do
    first_name { "FakeFirst" }
    last_name  { "FakeLast" }
    username { "Fakeyfakefake" }
    password { "fakepass" }
    email { "fake@fake.com" }
    role { "default" }
  end

  factory :admin, class: User do
    first_name { "FakeFirst" }
    last_name  { "FakeLast" }
    username { "admin" }
    password { "fakepass" }
    email { "admin@admin.com" }
    role { "admin" }
  end

  factory :rando_user, class: User do
    first_name { "FakeFirst" }
    last_name  { "FakeLast" }
    username { "randouser" }
    password { "randopass" }
    email { "rando@rando.com" }
    role { "default" }
  end

  factory :diff_user, class: User do
    first_name { "FakeFirst" }
    last_name  { "FakeLast" }
    username { "diffuser" }
    password { "diffpass" }
    email { "diff@diff.com" }
    role { "default" }
  end
end
