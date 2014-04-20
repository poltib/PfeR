# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Category.create(name: "Conseils", description: "A product.")
Category.create(name: "Courses", description: "Postez votre avis sur les courses.")
Category.create(name: "Entrainements", description: "Postez votre avis sur les entrainements.")
Category.create(name: "Tracés", description: "Postez votre avis sur les tracés.")
Category.create(name: "Questions", description: "Si vous avez une question, c'est ici que ça se passe.")
Category.create(name: "Site", description: "Discussions relatives au développement du site.")

EventType.create(name: "race")
EventType.create(name: "training")
EventType.create(name: "walk")
EventType.create(name: "golden race")