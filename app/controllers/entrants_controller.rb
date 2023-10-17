class EntrantsController < ApplicationController

  layout "application"

  def new
    @entrant = Entrant.new
  end

  def create
    @entrant = Entrant.new(entrant_params)

    if Entrant.where(archived: false).count < 300 and @entrant.save
      flash[:notice] = "Vaše přihláška byla přijata. Během jednoho dne Vám dorazí email, ve kterém najdete informace k zaplacení startovného."
      redirect_to entrants_path
    else
      render action: 'new'
    end
  end

  def index
    @entrants = Entrant.where(archived: false).order('surname ASC, first_name ASC')
  end

  private 

  def entrant_params
    params.require(:entrant).permit(:first_name, :surname, :email, :year, :club, :address, :climber, :male)
  end

end
