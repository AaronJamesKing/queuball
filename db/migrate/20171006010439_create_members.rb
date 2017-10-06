class CreateMembers < ActiveRecord::Migration[5.1]
  def change
    create_table :members do |t|
      t.references :user, foreign_key: true
      t.references :playlist, foreign_key: true
      t.integer :invited_by
      t.integer :accepted_by
    end
  end
end
