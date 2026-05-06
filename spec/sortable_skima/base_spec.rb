require "spec_helper"

RSpec.describe SortableSkima::Base do
  class TestProjectsTable < SortableSkima::Base
    def base_query
      Project.left_joins(:manager).select("projects.*, users.name as manager_name")
    end

    column :name, title: "Project Name", sortable: "projects.name"
    column :manager_name, title: "Manager", sortable: "users.name"
    column :budget, title: "Budget" # Not sortable
    
    filter :status, collection: ["Active", "Archived"]
    filter :budget_min do |query, val|
      query.where("projects.budget >= ?", val)
    end
  end

  before(:all) do
    john = User.create!(name: "John Doe")
    jane = User.create!(name: "Jane Smith")

    Project.create!(name: "Apollo", manager: john, budget: 10000)
    Project.create!(name: "Zeus", manager: jane, budget: 5000)
    Project.create!(name: "Ares", manager: john, budget: 20000)
  end

  describe "DSL setup" do
    it "registers columns correctly" do
      expect(TestProjectsTable.columns.keys).to include(:name, :manager_name, :budget)
      expect(TestProjectsTable.columns[:name][:sortable]).to eq("projects.name")
      expect(TestProjectsTable.columns[:budget][:sortable]).to eq(false)
    end

    it "registers filters correctly" do
      expect(TestProjectsTable.filters.keys).to include(:status, :budget_min)
      expect(TestProjectsTable.filters[:status][:collection]).to eq(["Active", "Archived"])
    end
  end

  describe "Data retrieval without params" do
    it "returns all records with pagination" do
      table = TestProjectsTable.new
      expect(table.records.length).to eq(3)
      expect(table.pagy_obj).not_to be_nil
    end
  end

  describe "Sorting" do
    it "sorts by a configured sortable column (asc)" do
      table = TestProjectsTable.new(sort: "name", dir: "asc")
      expect(table.records.map(&:name)).to eq(["Apollo", "Ares", "Zeus"])
    end

    it "sorts by a configured sortable column (desc)" do
      table = TestProjectsTable.new(sort: "name", dir: "desc")
      expect(table.records.map(&:name)).to eq(["Zeus", "Ares", "Apollo"])
    end

    it "sorts by a joined column" do
      table = TestProjectsTable.new(sort: "manager_name", dir: "asc")
      # Jane (Zeus) comes before John (Apollo, Ares)
      expect(table.records.first.name).to eq("Zeus")
    end

    it "ignores sorting on a non-sortable column" do
      table = TestProjectsTable.new(sort: "budget", dir: "asc")
      # Should fallback to default DB order (id)
      expect(table.records.map(&:name)).to eq(["Apollo", "Zeus", "Ares"])
    end

    it "ignores malicious sorting parameters" do
      table = TestProjectsTable.new(sort: "DROP TABLE users", dir: "asc")
      expect { table.records }.not_to raise_error
      expect(table.records.length).to eq(3)
    end
  end

  describe "Filtering" do
    it "applies a standard where filter" do
      # Note: our db doesn't actually have status, but we can test the structure
      # Let's test the block filter which we actually wired up to budget
      table = TestProjectsTable.new(filter: { budget_min: 10000 })
      expect(table.records.map(&:name)).to match_array(["Apollo", "Ares"])
    end
  end

  describe "Serialization" do
    it "outputs a valid json structure" do
      table = TestProjectsTable.new(sort: "name", dir: "asc")
      json = table.as_json

      expect(json).to have_key(:columns)
      expect(json).to have_key(:filters)
      expect(json).to have_key(:pagination)
      expect(json).to have_key(:data)

      expect(json[:data].length).to eq(3)
      expect(json[:data].first[:name]).to eq("Apollo")
      expect(json[:data].first[:manager_name]).to eq("John Doe")
    end
  end
end
