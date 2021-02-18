class CocktailsController < ApplicationController
  before_action :set_cocktail, only: [:show, :image]

  def index
    @cocktails = Cocktail.all
  end

  def show
    fetch_image unless @cocktail.img_url
    @dose = Dose.new
  end

  def new
    @cocktail = Cocktail.new
  end

  def create
    @cocktail = Cocktail.new(cocktail_params)
    @cocktail.save ? (redirect_to cocktail_path(@cocktail)) : (render :new)
  end

  private

  def set_cocktail
    @cocktail = Cocktail.find(params[:id])
  end

  def cocktail_params
    params.require(:cocktail).permit(:name)
  end

  def fetch_image
    url = URI.encode("https://www.thecocktaildb.com/api/json/v1/1/search.php?s=#{@cocktail.name}")
    drink = JSON.parse(URI(url)
                .read)['drinks']
                .first
    @cocktail.img_url = drink['strDrinkThumb']
    @cocktail.save
  end
end
