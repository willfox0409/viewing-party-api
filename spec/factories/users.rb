FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    username { Faker::Internet.unique.username(specifier: 5..12) }
    password { "password" }
    password_confirmation { "password" }
  end
end