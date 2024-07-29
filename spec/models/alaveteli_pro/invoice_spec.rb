require 'spec_helper'

RSpec.describe AlaveteliPro::Invoice, type: :model do
  let(:invoice) { AlaveteliPro::Invoice.new(stripe_invoice) }

  let(:stripe_invoice) do
    double('Stripe::Invoice',
           status: 'open', charge: 'ch_123', date: 1722211200)
  end

  let(:stripe_charge) do
    double('Stripe::Charge', receipt_url: 'http://example.com/receipt')
  end

  before do
    allow(Stripe::Charge).
      to receive(:retrieve).with('ch_123').and_return(stripe_charge)
  end

  describe '#open?' do
    it 'returns true when the status is open' do
      expect(invoice).to be_open
    end

    it 'returns false when the status is not open' do
      allow(stripe_invoice).to receive(:status).and_return('paid')
      expect(invoice).not_to be_open
    end
  end

  describe '#paid?' do
    it 'returns true when the status is paid' do
      allow(stripe_invoice).to receive(:status).and_return('paid')
      expect(invoice).to be_paid
    end

    it 'returns false when the status is not paid' do
      expect(invoice).not_to be_paid
    end
  end

  describe '#date' do
    it 'returns a date object for the invoice' do
      with_env_tz 'UTC' do
        expect(invoice.date).to eq(Date.new(2024, 7, 29))
      end
    end
  end

  describe '#charge' do
    it 'returns a Stripe::Charge object' do
      expect(invoice.charge).to eq(stripe_charge)
    end

    it 'memoizes the Stripe::Charge object' do
      expect(Stripe::Charge).to receive(:retrieve).once.with('ch_123')
      2.times { invoice.charge }
    end
  end

  describe '#receipt_url' do
    it 'delegates receipt_url to the charge' do
      expect(invoice.receipt_url).to eq('http://example.com/receipt')
    end
  end

  describe '#method_missing' do
    it 'forwards missing methods to the original object' do
      allow(stripe_invoice).
        to receive(:some_missing_method).and_return('result')
      expect(invoice.some_missing_method).to eq('result')
    end
  end
end
