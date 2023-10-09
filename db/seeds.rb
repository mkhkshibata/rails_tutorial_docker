# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

User.create(name: "サンプルユーザー",
						email: "example@rails.com",
						password: "foobarrr",
						password_confirmation: "foobarrr",
						admin: true,
						activated: true,
						activated_at: Time.zone.now)

99.times do |n|
	Faker::Config.locale = :ja
	name = Faker::Name.name
	email = "example-#{n + 1}@railstutorial.org"
	password = "password"
	User.create!(name: name,
								email: email,
								password: password,
								password_confirmation: password,
								activated: true,
								activated_at: Time.zone.now)
end

User.create(name: "test05",
	email: "test05@test.jp",
	password: "asdfasdf",
	password_confirmation: "asdfasdf",
	admin: true,
	activated: true,
	activated_at: Time.zone.now)

users = User.order(:created_at).take(6)
50.times do
	Faker::Config.locale = :ja
	content = Faker::Lorem.sentence(word_count: 5)
	users.each { |user| user.microposts.create!(content: content) }
end

users = User.all
user = users.first
following = users[2..50]
followed = users[3..40]
following.each { |followed| user.follow(followed) }
followed.each { |follower| follower.follow(user) }