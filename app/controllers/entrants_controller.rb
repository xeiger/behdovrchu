class EntrantsController < ApplicationController

  layout "application"

  def new
    @entrant = Entrant.new
  end

  def create
    @entrant = Entrant.new(entrant_params)

    if @entrant.save
      flash[:notice] = "Vaše přihláška byla přijata, v emailu najdete informace k zaplacení startovného."
      redirect_to entrants_path
    else
      render action: 'new'
    end
  end

  def index
    @entrants = Entrant.all.order('surname ASC, first_name ASC')
  end

  private 

  def entrant_params
    params.require(:entrant).permit(:first_name, :surname, :email, :year, :club, :address)
  end

end
