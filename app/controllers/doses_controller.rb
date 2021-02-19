class DosesController < ApplicationController
  before_action :set_cocktail, except: :destroy

  def new
    @dose = Dose.new
  end

  def create
    @dose = Dose.new(dose_params)
    @dose.cocktail = @cocktail
    @dose.save ? (redirect_to cocktail_path(@cocktail)) : (render 'cocktails/show')
  end

  def destroy
    @dose = Dose.find(params[:id])
    @dose.destroy
    # redirect_to cocktail_path(@cocktail)
  end

  private

  def set_cocktail
    @cocktail = Cocktail.find(params[:cocktail_id])
  end

  def dose_params
    params.require(:dose).permit(:cocktail, :ingredient_id, :description)
  end
end
