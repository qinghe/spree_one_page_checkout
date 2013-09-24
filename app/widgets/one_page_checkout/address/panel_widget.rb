class OnePageCheckout::Address::PanelWidget < Apotomo::Widget
  responds_to_event :address_created

  has_widgets do |root|
    root << widget('one_page_checkout/address/address', :address_book_entry)
    root << widget('one_page_checkout/address/address', :new_address_book_entry)
  end

  def display(user)
    @user = user

    render
  end

  def address_created(event)
    replace({ state: :display }, event.data.fetch(:user))
  end
end
