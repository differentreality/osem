# frozen_string_literal: true

class SponsorEmailJob < ApplicationJob
  queue_as :default

  def perform(sponsor, conference, from, subject, body)
    Mailbot.sponsor_email(sponsor, conference, from, subject, body).deliver_now
  end
end
