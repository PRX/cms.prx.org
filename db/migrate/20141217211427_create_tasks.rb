class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :type
      t.string :identifier
      t.integer :status, default: 0
      t.references :owner, polymorphic: true, index: true

      t.text :options
      t.text :result

      t.timestamps
    end
  end
end
