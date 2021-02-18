class CocktailsController < ApplicationController
  before_action :set_cocktail, only: [:show, :image]

  def index
    @cocktails = Cocktail.all
  end

  def show
    # fetch_image unless @cocktail.img_url
    @dose = Dose.new
  end

  def new
    @cocktail = Cocktail.new
  end

  def create
    @cocktail = Cocktail.new(cocktail_params)
    write_details
    @cocktail.save ? write_doses : (render :new)
  end

  private

  def write_details
    @json_data = fetch_cocktail_json
    @cocktail.cocktaildb_id = set_cocktaildb_id
    @cocktail.instructions = set_instructions
    @cocktail.img_url = set_img_url
  end

  def write_doses
    ingredients = select_ingredients
    measures = select_measures
    ingredients.each_with_index do |key, index|
      @cocktail.doses << Dose.create(
        description: measures[index],
        cocktail_id: @cocktail.id,
        ingredient_id: (Ingredient.find_by name: ingredients[key])
      )
    end
    redirect_to cocktail_path(@cocktail)
  end

  def set_cocktail
    @cocktail = Cocktail.find(params[:id])
  end

  def cocktail_params
    params.require(:cocktail).permit(:name)
  end

  def fetch_cocktail_json
    url = URI.encode("https://www.thecocktaildb.com/api/json/v1/1/search.php?s=#{@cocktail.name}")
    JSON.parse(URI(url)
        .read)['drinks']
        .first
  end

  def set_cocktaildb_id
    @json_data['idDrink'].to_i
  end

  def set_instructions
    @json_data['strInstructions']
  end

  def set_img_url
    @json_data['strDrinkThumb']
  end

  def select_ingredients
    @json_data.select do |key, value|
      key.start_with?('strIngredient') && !value.nil?
    end
  end

  def select_measures
    @json_data.select do |key, value|
      key.start_with?('strMeasure') && !value.nil?
    end
  end
end
