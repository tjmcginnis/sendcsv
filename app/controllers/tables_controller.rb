class TablesController < ApplicationController
  def index
    @tables = Current.user.tables
  end
end
