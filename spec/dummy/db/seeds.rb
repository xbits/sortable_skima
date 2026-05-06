puts "Seeding Projects..."
Project.destroy_all

managers = ["John Doe", "Jane Smith", "Alice Johnson", "Bob Brown"]
statuses = ["Active", "Archived", "Pending"]

50.times do |i|
  Project.create!(
    name: "Project Alpha-#{i}",
    manager_name: managers.sample,
    budget: rand(5000..50000),
    status: statuses.sample
  )
end

puts "Created #{Project.count} projects."
