class CreateSuspensions < ActiveRecord::Migration[5.2]
  def change
    create_table :suspensions do |t|
      t.references :user, foreign_key: true
      t.boolean :is_suspended

      t.timestamps
    end
  end
end
