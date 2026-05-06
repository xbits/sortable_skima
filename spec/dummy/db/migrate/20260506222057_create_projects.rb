class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.string :name
      t.string :manager_name
      t.integer :budget
      t.string :status

      t.timestamps
    end
  end
end
