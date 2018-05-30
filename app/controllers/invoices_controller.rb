class InvoicesController < ApplicationController
  load_and_authorize_resource :conference, find_by: :short_title
  load_and_authorize_resource :user
  load_and_authorize_resource through: :user

  # GET /invoices
  # GET /invoices.json
  def index
    @invoices = current_user.invoices.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @invoices }
    end
  end

  # GET /invoices/1
  # GET /invoices/1.json
  def show
    respond_to do |format|
      format.html
      format.pdf do
        html = render_to_string(action: 'show.html.haml', layout: 'invoice_pdf')
        kit = PDFKit.new(html, margin_top: '0in')
        filename = "invoice_#{@invoice.no}_#{@invoice.date.strftime('%Y-%m')}_#{@invoice.conference.short_title}.pdf"

        send_data kit.to_pdf, filename: filename, type: 'application/pdf'
        return
      end
      format.json { render json: @invoice }
    end
  end
end
