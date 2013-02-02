class PagesController < ApplicationController

  skip_before_filter :authenticate_user!, :except => :servers

  def welcome
    @reservations = Reservation.within_12_hours
    if current_user
      @users_reservations = current_user.reservations.ordered.first(5)
    end
  end

  def credits
  end

  def servers
    @servers = Server.reservable_by_user(current_user)
  end

  def recent_reservations
    @recent_reservations = Statistic.recent_reservations
  end

  def top_10
    @top_10_hash = Statistic.top_10
  end

end
