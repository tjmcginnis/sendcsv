class TablesController < ApplicationController
  def index
    @tables = tables
  end

  def show
    @table = tables.with_rows.find_by!(public_id: params[:public_id])

    respond_to do |format|
      format.html
      format.csv do
        send_data @table.to_csv, filename: "#{@table.public_id}.csv"
      end
    end
  end

  private
    def tables
      Current.user.tables
    end
end
