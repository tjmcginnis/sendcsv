class IngestionsController < ApplicationController
  rate_limit to: 5, within: 1.second, only: :create
  allow_unauthenticated_access only: [ :create ]
  skip_before_action :verify_authenticity_token, only: [ :create ]

  before_action :validate_csv_content_type, only: [ :create ]

  def create
    ingestion = table.ingestions.create(status: :pending)
    ingestion.process(request.body.read)
    render json: { message: "Ingestion created successfully", ingestion_id: ingestion.public_id }, status: :created
  rescue StandardError => e
    logger.debug("Ingestion failed with error: #{e.message}")
    render json: { error: "Unable to process ingestion" }, status: :unprocessable_entity
  end

  private
    def validate_csv_content_type
      unless request.headers["Content-Type"] == "text/csv"
        render json: { error: "Invalid content type" }, status: :unsupported_media_type
      end
    end

    def table
      @table ||= Table.find_by!(public_id: params[:table_id])
    end
end
