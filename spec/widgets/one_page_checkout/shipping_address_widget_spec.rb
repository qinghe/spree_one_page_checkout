require 'spec_helper'

def register_widget
  has_widgets do |root|
    root << widget('one_page_checkout/shipping_address', :opco_shipping_address, user: current_user, order: current_order)
  end
end

module OnePageCheckout
  describe ShippingAddressWidget do
    register_widget

    let(:current_user) { double(:current_user, addresses: []) }
    let(:current_order) { double(:current_order) }

    let(:rendered) { render_widget(:opco_shipping_address, :display) }

    it "renders the shipping-address address-book" do
      expect(rendered).to have_selector("[data-hook=opco-shipping-address]")
      expect(rendered).to have_selector("[data-hook=opco-shipping-address] > [data-hook=opco-address-book]")
    end

    context "when receiving an :address_created event" do
      register_widget

      let(:shipping_address_widget) { root.find_widget(:opco_shipping_address) }
      let(:new_address) { double(:new_address) }

      before do
        current_order.stub(:update_attribute)
      end

      it "assigns the new address as the order's shipping address" do
        expect(current_order).to receive(:update_attribute).with(:ship_address, new_address)

        trigger!
      end

      it "triggers a :shipping_address_updated event" do
        expect(shipping_address_widget).to receive(:trigger).with(:shipping_address_updated)

        trigger!
      end


      def trigger!
        trigger(:address_created, :opco_shipping_address, new_address: new_address)
      end
    end
  end
end