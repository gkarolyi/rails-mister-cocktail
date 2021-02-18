class AddDetailsToCocktails < ActiveRecord::Migration[6.1]
  def change
    add_column :cocktails, :cocktaildb_id, :integer
    add_column :cocktails, :instructions, :text
  end
end
