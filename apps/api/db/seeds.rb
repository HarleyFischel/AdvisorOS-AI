def upsert_organization(name, slug)
  Organization.find_or_create_by!(slug: slug) { |org| org.name = name }
end

primary = upsert_organization("Northstar Wealth Partners", "northstar-wealth")
isolated = upsert_organization("Cedar Ridge Advisory", "cedar-ridge")

def upsert_user(org, email, name, role)
  user = User.find_or_initialize_by(email: email)
  user.assign_attributes(organization: org, full_name: name, role: role, password: "DemoPass!2026")
  user.save!
  user
end

admin = upsert_user(primary, "admin@northstar.demo", "Avery Admin", "admin")
advisor = upsert_user(primary, "advisor@northstar.demo", "Jordan Advisor", "advisor")
viewer = upsert_user(primary, "viewer@northstar.demo", "Taylor Viewer", "viewer")
upsert_user(isolated, "admin@cedarridge.demo", "Morgan Isolated", "admin")

households = 10.times.map do |index|
  primary.households.find_or_create_by!(name: "Demo Household #{index + 1}") { |h| h.description = "Synthetic planning household for portfolio demonstration." }
end

30.times do |index|
  client = primary.clients.find_or_initialize_by(email: "client#{index + 1}@demo.invalid")
  client.assign_attributes(
    first_name: %w[Alex Blake Casey Devon Emery Finley].fetch(index % 6),
    last_name: "Demo#{index + 1}",
    phone: "555-010#{format('%02d', index)}",
    status: Client.statuses.keys.fetch(index % 3),
    estimated_aum: ((index + 1) * 125_000) + (index % 4) * 25_000,
    household: households.fetch(index % households.length),
    assigned_user: index.even? ? advisor : admin
  )
  client.save!
end

clients = primary.clients.order(:created_at).to_a
stages = Opportunity.stages.keys
15.times do |index|
  primary.opportunities.find_or_create_by!(title: "Synthetic Planning Opportunity #{index + 1}") do |opportunity|
    opportunity.client = clients.fetch(index % clients.length)
    opportunity.owner_user = index.even? ? advisor : admin
    opportunity.stage = stages.fetch(index % stages.length)
    opportunity.estimated_value = (index + 1) * 75_000
    opportunity.expected_close_date = (index + 2).months.from_now.to_date
  end
end

40.times do |index|
  client = clients.fetch(index % clients.length)
  primary.activities.find_or_create_by!(client: client, summary: "Synthetic activity #{index + 1}") do |activity|
    activity.user = index.even? ? advisor : admin
    activity.activity_type = Activity.activity_types.keys.fetch(index % Activity.activity_types.keys.length)
    activity.occurred_at = index.days.ago
  end
end

puts "Seeded #{Organization.count} organizations, #{User.count} users, #{Client.count} clients, #{Household.count} households, #{Opportunity.count} opportunities, and #{Activity.count} activities."
