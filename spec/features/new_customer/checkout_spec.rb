require 'spec_helper'

# In order to pay for the massive slab of Nebraska beef in his cart
# As a brand-new customer
# Homer Simpson can check out

describe "A new customer", type: :feature, js: true do
  before(:all) { configure_store }

  before do
    sign_up!
  end

  let(:beef_slab) { create(:product) }
  let!(:shipping_method) { create(:shipping_method) }

  context "with a credit card" do
    it "completes a checkout" do
      visit spree.product_path(beef_slab)

      # product.add_to_cart
      click_button 'Add To Cart'

      # cart.checkout
      click_button 'Checkout'

      expect(current_path).to eq '/checkout'
      expect(page).to_not have_css('[data-hook=opco-existing-shipping-address]')

      # (Temporary) DMA objects
      current_user  = Spree::User.first
      current_order = Spree::User.first.orders.first

      # address.supply
      within '[data-hook=opco-shipping-address-book]' do
        click_on 'Add Address'

        within '[data-hook=opco-new-shipping-address] form' do
          fill_in 'First Name', with: 'Guy'
          fill_in 'Last Name', with: 'Incognito'
          fill_in 'Address', with: '1234 Fake St.'
          fill_in 'City', with: 'New York City'
          select 'New York', from: 'State'
          fill_in 'Zip Code', with: '10001'
          fill_in 'Telephone', with: '555-555-1234'

          # Use the default country
          # select 'United States', from: 'Country'

          click_button 'Save'
        end
      end

      expect(current_path).to eq '/checkout'

      expect(page).to have_css('[data-hook=opco-existing-shipping-address]', count: 1, text: /1234 Fake St/)
      expect(page).to have_css('[data-hook=opco-new-shipping-address]', count: 1)

      # (Temporary) DMA expectations to motivate integration with orders
      current_order.reload.ship_address.tap do |shipping_address|
        expect(shipping_address.lastname).to match /Incognito/
        expect(shipping_address.address1).to match /1234 Fake St/
      end

      # shipping_method.choose
      within '[data-hook=opco-delivery-method]' do
        select shipping_method.name
      end

      expect(current_path).to eq '/checkout'

      current_order.reload.shipping_method.tap do |shipping_method|
        expect(shipping_method).to eq shipping_method
      end

      pending_further_implementation!

      # credit_card.supply
      within '[data-hook=opco-payment-method]' do
        within '[data-hook=opco-card-details]' do
          fill_in 'Card Number', with: '4111111111111111'
          select '01', from: 'Expiration Month'
          select '2015', from: 'Expiration Year'
          fill_in 'Card Verification Value', with: '123'
        end

        within '[data-hook=opco-billing-address]' do
          fill_in 'Full Name', with: 'Guy Incognito'
          fill_in 'Address', with: '1234 Fake St.'
          fill_in 'City', with: 'New York City'
          select 'New York', from: 'State'
          select 'United States', from: 'Country'
          fill_in 'Zip Code', with: '10001'
          fill_in 'Telephone', with: '555-555-1234'
        end
      end

      expect(current_path).to eq '/checkout'

      # confirmation.confirm
      click_on 'Confirm My Order'

      expect(page).to have_content "Your order was processed successfully."
    end
  end

  context "with PayPal" do
    it "completes a checkout"
  end

  context "with store credit" do
    it "completes a checkout"
  end

  def pending_further_implementation!
    sleep 2
    pending "further implementation"
  end
end
