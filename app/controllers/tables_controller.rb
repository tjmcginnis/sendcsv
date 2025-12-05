class TablesController < ApplicationController
  def index
    @tables = tables
  end

  def show
    @table = tables.with_rows.find_by!(public_id: params[:public_id])
  end

  private
    def tables
      Current.user.tables
    end
end
