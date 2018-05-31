class PdfsController < ApplicationController
  skip_authorization_check

  def footer
    # authorize! :footer, 'Pdf'
    render :layout => false
  end

  # def header
  #   authorize! :footer, 'Pdf'
  #   @target = params[:target]
  #   @companies_length = params[:companies_length] || 0
  #   @assets_value = params[:assets_value]
  #   render :layout => false
  # end
end
