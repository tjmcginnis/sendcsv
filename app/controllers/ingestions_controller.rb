class IngestionsController < ApplicationController
  rate_limit to: 5, within: 1.second, only: :create
  allow_unauthenticated_access only: [ :create ]
  skip_before_action :verify_authenticity_token, only: [ :create ]

  before_action :ensure_csv_content_type, only: [ :create ]
  before_action :ensure_body_size_within_limit, only: [ :create ]

  MAX_BODY_SIZE = 256.kilobytes

  def create
    ingestion = table.ingestions.create(status: :pending)
    ingestion.process(body_content)
    render json: { message: "Ingestion created successfully", ingestion_id: ingestion.public_id }, status: :created
  rescue StandardError => e
    logger.debug("Ingestion failed with error: #{e.message}")
    render json: { error: "Unable to process ingestion" }, status: :unprocessable_entity
  end

  private
    def ensure_csv_content_type
      unless request.headers["Content-Type"] == "text/csv"
        render json: { error: "Invalid content type" }, status: :unsupported_media_type
      end
    end

    def ensure_body_size_within_limit
      if body_content.bytesize > MAX_BODY_SIZE
        render json: { error: "Request body exceeds 256KB limit" }, status: :content_too_large
      end
    end

    def table
      @table ||= Table.find_by!(public_id: params[:table_id])
    end

    def body_content
      @body_content ||= request.body.read(MAX_BODY_SIZE + 1)
    end
end
