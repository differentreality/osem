module Admin
  class InvoicesController < Admin::BaseController
    load_and_authorize_resource
    load_and_authorize_resource :conference, find_by: :short_title
    load_resource :physical_ticket
    # before_action :set_invoice, only: [:show, :edit, :update, :destroy]

    # GET /invoices
    # GET /invoices.json
    def index
      @invoices = Invoice.all

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @invoices }
      end
    end

    # GET /invoices/1
    # GET /invoices/1.json
    def show
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @invoice }
      end
    end

    # GET /invoices/new
    def new
      @invoice = @conference.invoices.new
      @ticket_purchases_collection = @conference.ticket_purchases.where(user: @physical_ticket.user).group_by(&:ticket).map{ |ticket, purchases| [ticket, quantity: purchases.sum(&:quantity), total_price: purchases.sum(&:amount_paid)] }.map{|ticket, data| [ticket.title, ticket.id, data: { ticket_name: ticket.title, quantity: data[:quantity], total_price: data[:total_price]} ]}
      @url = @invoice.new_record? ? admin_conference_invoices_path(@conference.short_title) : admin_conference_invoice_path(@conference.short_title, @invoice)
    end

    # GET /invoices/1/edit
    def edit
    end

    # POST /invoices
    # POST /invoices.json
    def create
      @invoice = Invoice.new(invoice_params)

      respond_to do |format|
        if @invoice.save
          format.html { redirect_to @invoice, notice: 'Invoice was successfully created.' }
          format.json { render json: @invoice, status: :created }
        else
          format.html { render action: 'new' }
          format.json { render json: @invoice.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /invoices/1
    # PATCH/PUT /invoices/1.json
    def update
      respond_to do |format|
        if @invoice.update(invoice_params)
          format.html { redirect_to @invoice, notice: 'Invoice was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @invoice.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /invoices/1
    # DELETE /invoices/1.json
    def destroy
      @invoice.destroy
      respond_to do |format|
        format.html { redirect_to invoices_url }
        format.json { head :no_content }
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_invoice
        @invoice = Invoice.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def invoice_params
        params.require(:invoice).permit(:no, :date, :user_id_id, :conference_id_id, :description, :quantity, :total_quantity, :item_price, :total_price, :total_amount, :vat, :payable, :payable_text, :quantity_text, :paid)
      end
  end
end
