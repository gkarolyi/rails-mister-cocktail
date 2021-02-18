class AddImgUrlToCocktails < ActiveRecord::Migration[6.1]
  def change
    add_column :cocktails, :img_url, :string
  end
end
