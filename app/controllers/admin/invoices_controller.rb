module Admin
  class InvoicesController < Admin::BaseController
    load_and_authorize_resource
    load_and_authorize_resource :conference, find_by: :short_title
    load_resource :physical_ticket
    load_resource :payment, except: :create
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
      @user = @payment.user
      ticket_purchases = if @payment
                          #  @payment.ticket_purchases
                           @conference.ticket_purchases.where(user: @payment.user)
                         else
                           # CHANGEME - FIND USER
                           @conference.ticket_purchases.where(user: @payment.user)
                         end


      @user_tickets = ticket_purchases.select(&:payment).group_by(&:ticket).map{ |ticket, purchases| [ticket, quantity: purchases.sum(&:quantity), total_price: purchases.sum(&:amount_paid)] }.to_h

      total_amount = @user_tickets.values.map{ |h| h[:total_price]}.sum || 0
      vat_percent = ENV['VAT_PERCENT'].to_f
      vat = total_amount * vat_percent / 100
      payable = total_amount + vat

      @invoice = @conference.invoices.new(total_amount: total_amount,
                                          vat_percent: vat_percent,
                                          vat: vat,
                                          payable: payable)

      @user_tickets_collection = @user_tickets.map{|ticket, data| ["#{ticket.title} (#{data[:quantity]})", ticket.id, data: { ticket_name: ticket.title, quantity: data[:quantity], total_price: data[:total_price]} ]}

      # .map(&:ticket).map{ |purchase| ["#{purchase.ticket.title} (#{purchase.quantity})", purchase.id] }
      # @ticket_purchases_collection = @conference.ticket_purchases.where(user: @physical_ticket.user).group_by(&:ticket).map{ |ticket, purchases| [ticket, quantity: purchases.sum(&:quantity), total_price: purchases.sum(&:amount_paid)] }.map{|ticket, data| [ticket.title, ticket.id, data: { ticket_name: ticket.title, quantity: data[:quantity], total_price: data[:total_price]} ]}
      @url = @invoice.new_record? ? admin_conference_invoices_path(@conference.short_title) : admin_conference_invoice_path(@conference.short_title, @invoice)
    end

    # GET /invoices/1/edit
    def edit
    end

    # POST /invoices
    # POST /invoices.json
    def create
      @invoice = @conference.invoices.new(invoice_params)
      @payment = Payment.find(params[:payment_id])
      @user = @payment.user

      respond_to do |format|
        if @invoice.save
          format.html { redirect_to admin_conference_invoice_path(@conference.short_title, @invoice), notice: 'Invoice was successfully created.' }
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
        params.require(:invoice).permit(:no, :date, :user_id, :conference_id,
                                        :description,
                                        :quantity, :total_quantity,
                                        :item_price, :total_price,
                                        :total_amount, :vat_percent, :vat,
                                        :payable, :paid,
                                        :payment_id, payment_ids: [] )
      end
  end
end
