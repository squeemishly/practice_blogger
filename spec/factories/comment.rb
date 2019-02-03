FactoryBot.define do
  factory :comment do
    user
    article
    body { "Fake Comment" }
  end
end
