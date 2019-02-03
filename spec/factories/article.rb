FactoryBot.define do
  factory :article do
    user
    title { "Fake Title" }
    body { "Fake Body" }
  end
end
