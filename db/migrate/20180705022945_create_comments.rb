class CreateComments < ActiveRecord::Migration[5.0]
  def change
    create_table :comments do |t|
      t.integer :user_id
      t.integer :movie_id
      t.text :contents

      t.timestamps
    end
  end
end
