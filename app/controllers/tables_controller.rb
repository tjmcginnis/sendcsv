class TablesController < ApplicationController
  def index
    @tables = Current.user.tables
  end

  def show
    @table = Current.user.tables.find_by!(public_id: params[:public_id])
  end
end
