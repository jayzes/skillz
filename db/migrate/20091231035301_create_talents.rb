class CreateTalents < ActiveRecord::Migration
  def self.up
    create_table :talents do |t|
      t.integer :person_id
      t.integer :skill_id

      t.timestamps
    end
  end

  def self.down
    drop_table :talents
  end
end
