# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Category.create(name: "Conseils")
Category.create(name: "Courses")
Category.create(name: "Entrainements")
Category.create(name: "Tracés")
Category.create(name: "Questions")
Category.create(name: "Site")

EventType.create(name: "Course")
EventType.create(name: "Entrainement")
EventType.create(name: "Marche")
EventType.create(name: "Golden race")