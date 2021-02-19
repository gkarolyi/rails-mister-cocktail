class CocktailsController < ApplicationController
  before_action :set_cocktail, only: [:show, :update]

  def index
    @cocktails = Cocktail.all
  end

  def show
    @dose = Dose.new
  end

  def new
    @cocktail = Cocktail.new
  end

  def create
    @cocktail = Cocktail.new(cocktail_params)
    @cocktail.save ? (redirect_to cocktail_path(@cocktail)) : (render :new)
  end

  def update
    write_doses if write_details
  end

  private

  def write_details
    @json_data = fetch_cocktail_json
    return if @json_data.nil?

    @cocktail.cocktaildb_id = set_cocktaildb_id
    @cocktail.instructions = set_instructions
    @cocktail.img_url = set_img_url
    @cocktail.save
  end

  def write_doses
    create_doses_hash.each do |key, value|
      Dose.create(
        description: value,
        cocktail: @cocktail,
        ingredient: Ingredient.find_by(name: key) || Ingredient.create!(name: key)
      )
    end
    redirect_to cocktail_path(@cocktail)
  end

  def create_doses_hash
    ingredients = select_ingredients
    measures = select_measures
    loop do
      return Hash[ingredients.zip(measures)] if measures.length == ingredients.length

      measures.length < ingredients.length ? measures.push('') : ingredients.push('')
    end
  end

  def set_cocktail
    @cocktail = Cocktail.find(params[:id])
  end

  def cocktail_params
    params.require(:cocktail).permit(:name)
  end

  def fetch_cocktail_json
    url = URI.encode("https://www.thecocktaildb.com/api/json/v1/1/search.php?s=#{@cocktail.name}")
    data = JSON.parse(URI(url).read)['drinks']
    return if data.nil?

    data.first
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
    @json_data
      .select do |key, value|
        key.start_with?('strIngredient') && !value.nil?
      end
      .values
  end

  def select_measures
    @json_data
      .select do |key, value|
        key.start_with?('strMeasure') && !value.nil?
      end
      .values
  end
end
