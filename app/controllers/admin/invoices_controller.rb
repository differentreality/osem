module Admin
  class InvoicesController < Admin::BaseController
    load_and_authorize_resource
    load_and_authorize_resource :conference, find_by: :short_title
    load_resource :physical_ticket
    load_resource :payment, except: :create
    load_resource :sponsor, only: :new

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

    # GET /invoices/new
    def new
      @user = @payment.try(:user)
      if params[:kind] == 'ticket_purchases'
        ticket_purchases = if @payment
                            #  @payment.ticket_purchases
                             @conference.ticket_purchases.where(payment: @payment)
                           else
                             # CHANGEME - FIND USER
                             @conference.ticket_purchases.where(user: @payment.user).paid
                           end
        @ticket_purchase_ids = ticket_purchases.pluck(:id)
        @ticket_purchases = ticket_purchases

        # [[ticket1, q: 5, price: 50], [ticket2, q: 2, price: 80]]
        @user_tickets = ticket_purchases.group_by(&:ticket).map{|ticket, purchases| [ticket, purchases.group_by(&:amount_paid).map{|amount, p| [amount, p.pluck(:quantity).sum, p.pluck(:id)] }  ]}.to_h.map{|ticket, p| p.map{|x| { :ticket => ticket, :price => x.first, :quantity => x.second, :ticket_purchase_ids => x.last} } }.flatten

        # @user_tickets = ticket_purchases.group_by(&:ticket).map{ |ticket, purchases| [ticket, quantity: purchases.sum(&:quantity), total_price: purchases.sum(&:amount_paid)] }.to_h

        # @user_tickets_collection = @user_tickets.map{|ticket, data| ["#{ticket.title} (#{data[:quantity]})", ticket.id, data: { ticket_name: ticket.title, quantity: data[:quantity], total_price: data[:total_price]} ]}

        @user_tickets_collection = @user_tickets.map.with_index(1){|data, index| ["#{data[:ticket].title} (#{data[:quantity]} * #{data[:price]} #{data[:ticket].price_currency})", index, data[:ticket].id, data: { ticket_name: data[:ticket].title, quantity: data[:quantity], price: data[:price]} ]}

        total_amount= @user_tickets.sum{|p| p[:price] * p[:quantity]}.to_f
      else #params[:kind] == 'sponsorship'
        total_amount = 0
      end


      vat_percent = ENV['VAT_PERCENT'].to_f
      vat = total_amount * vat_percent / 100
      payable =  '%.2f' % ((total_amount + vat).to_f)
      # description = @user_tickets.map{|ticket, data| { :description => ticket.title, :quantity => data[:quantity], :price => data[:total_price]} }

      no = Invoice.order(created_at: :asc).last.no + 1

      @invoice = @conference.invoices.new(no: no, date: Date.current,
                                          total_amount: total_amount,
                                          vat_percent: vat_percent,
                                          vat: vat,
                                          payable: payable)


      # .map(&:ticket).map{ |purchase| ["#{purchase.ticket.title} (#{purchase.quantity})", purchase.id] }
      # @ticket_purchases_collection = @conference.ticket_purchases.where(user: @physical_ticket.user).group_by(&:ticket).map{ |ticket, purchases| [ticket, quantity: purchases.sum(&:quantity), total_price: purchases.sum(&:amount_paid)] }.map{|ticket, data| [ticket.title, ticket.id, data: { ticket_name: ticket.title, quantity: data[:quantity], total_price: data[:total_price]} ]}
      @url = admin_conference_invoices_path(@conference.short_title)
    end

    # GET /invoices/1/edit
    def edit
      @url = admin_conference_invoice_path(@conference.short_title, @invoice)
      @user_tickets = @invoice.ticket_purchases.group_by(&:ticket).map{|ticket, purchases| [ticket, purchases.group_by(&:amount_paid).map{|amount, p| [amount, p.pluck(:quantity).sum, p.pluck(:id)] }  ]}.to_h.map{|ticket, p| p.map{|x| { :ticket => ticket, :price => x.first, :quantity => x.second, :ticket_purchase_ids => x.last} } }.flatten

      @user_tickets_collection = @user_tickets.map.with_index(1){|data, index| ["#{data[:ticket].title} (#{data[:quantity]} * #{data[:price]} #{data[:ticket].price_currency})", index, data[:ticket].id, data: { ticket_name: data[:ticket].title, quantity: data[:quantity], price: data[:price]} ]}
    end

    # POST /invoices
    # POST /invoices.json
    def create
      @invoice = @conference.invoices.new(invoice_params)
      @payment = Payment.find(params[:payment_id]) if params[:payment_id].present?
      @user = @payment.try(:user)

      if invoice_params[:ticket_purchase_ids].present?
        ticket_purchase_ids = invoice_params[:ticket_purchase_ids].split.map(&:to_i)
        ticket_purchases = TicketPurchase.where(id: ticket_purchase_ids)

        @invoice.ticket_purchase_ids = ticket_purchase_ids

        @user_tickets = ticket_purchases.group_by(&:ticket).map{|ticket, purchases| [ticket, purchases.group_by(&:amount_paid).map{|amount, p| [amount, p.pluck(:quantity).sum, p.pluck(:id)] }  ]}.to_h.map{|ticket, p| p.map{|x| { :ticket => ticket, :price => x.first, :quantity => x.second, :ticket_purchase_ids => x.last} } }.flatten

        @user_tickets_collection = @user_tickets.map.with_index(1){|data, index| ["#{data[:ticket].title} (#{data[:quantity]} * #{data[:price]} #{data[:ticket].price_currency})", index, data[:ticket].id, data: { ticket_name: data[:ticket].title, quantity: data[:quantity], price: data[:price]} ]}
      end

      respond_to do |format|
        if @invoice.save
          format.html { redirect_to admin_conference_invoice_path(@conference.short_title, @invoice), notice: 'Invoice was successfully created.' }
          format.json { render json: @invoice, status: :created }
        else
          @url = admin_conference_invoices_path(@conference.short_title)

          format.html { render action: 'new' }
          format.json { render json: @invoice.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /invoices/1
    # PATCH/PUT /invoices/1.json
    def update
      # @payment = Payment.find(params[:payment_id])

      ticket_purchase_ids = invoice_params[:ticket_purchase_ids].split.map(&:to_i)
      ticket_purchases = TicketPurchase.where(id: ticket_purchase_ids)

      @invoice.ticket_purchase_ids = ticket_purchase_ids

      @user_tickets = ticket_purchases.group_by(&:ticket).map{|ticket, purchases| [ticket, purchases.group_by(&:amount_paid).map{|amount, p| [amount, p.pluck(:quantity).sum, p.pluck(:id)] }  ]}.to_h.map{|ticket, p| p.map{|x| { :ticket => ticket, :price => x.first, :quantity => x.second, :ticket_purchase_ids => x.last} } }.flatten

      @user_tickets_collection = @user_tickets.map.with_index(1){|data, index| ["#{data[:ticket].title} (#{data[:quantity]} * #{data[:price]} #{data[:ticket].price_currency})", index, data[:ticket].id, data: { ticket_name: data[:ticket].title, quantity: data[:quantity], price: data[:price]} ]}


      respond_to do |format|
        if @invoice.update(invoice_params)
          format.html { redirect_to admin_conference_invoice_path(@conference.short_title, @invoice), notice: 'Invoice was successfully updated.' }
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

    def add_item
      respond_to do |format|
        format.js
      end
    end

    private

      # Never trust parameters from the scary internet, only allow the white list through.
      def invoice_params
        params.require(:invoice).permit(:no, :date, :user_id, :conference_id,
                                        :recipient, :quantity, :total_quantity,
                                        :item_price, :total_price,
                                        :total_amount, :vat_percent, :vat,
                                        :payable, :paid, :kind, :ticket_purchase_ids,
                                        :payment_id, payment_ids: [],
                                        description: [:description, :quantity, :price] )
      end
  end
end
