class InternalPriceController < ApplicationController

 def index
 	@internal_price = InternalPrice.new
  @marketing_price = MarketingPrice.new
  @raw_file = RawFile.new
  @internal_details = InternalPrice.all.page(params[:drug_page]).per(30)
 end

 def internal_file_bulk_upload
    InternalPrice.process_file(internal_file_bulk_upload_file)
    flash[:success] = 'Internal File successfully uploaded'
    redirect_back(fallback_location: root_path)
  end

  def internal_file_bulk_upload_file
    InternalPrice.open_spreadsheet(params[:internal_price][:file])
  end

  def raw_file_bulk_upload
    RawFile.process_file(raw_file_bulk_upload_file)
    flash[:success] = 'Raw File successfully uploaded'
    redirect_back(fallback_location: root_path)
  end

  def raw_file_bulk_upload_file
    RawFile.open_spreadsheet(params[:raw_files][:file])
  end

  def marketing_price_bulk_upload
    MarketingPrice.process_file(marketing_price_bulk_upload_file)
    flash[:success] = 'Market Price File successfully uploaded'
    redirect_back(fallback_location: root_path)
  end

  def marketing_price_bulk_upload_file
    MarketingPrice.open_spreadsheet(params[:marketing_prices][:file])
  end

end
