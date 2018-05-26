# frozen_string_literal: true

class RequestInvoiceMailJob < ApplicationJob
  queue_as :default

  def perform(physical_ticket)
    Rails.logger.debug "IN job to request invoice"
    Mailbot.invoice_request(physical_ticket).deliver_later
    Rails.logger.debug "IN job to request invoice: CAlled mailbot"
  end
end
