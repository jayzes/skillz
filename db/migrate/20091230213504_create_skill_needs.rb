class CreateSkillNeeds < ActiveRecord::Migration
  def self.up
    create_table :skill_needs do |t|
      t.integer :skill_id
      t.integer :project_id

      t.timestamps
    end
  end

  def self.down
    drop_table :skill_needs
  end
end
