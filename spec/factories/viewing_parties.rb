FactoryBot.define do
  factory :viewing_party do
    name { "FactoryBot Movie Night" }
    start_time { Time.now + 1.day }
    end_time { Time.now + 1.day + 3.hours }
    movie_id { 278 }
    movie_title { "The Shawshank Redemption" }
  end
end