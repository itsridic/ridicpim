class Account < ApplicationRecord
  RESTRICTED_SUBDOMAINS = %w(www)

  belongs_to :owner, class_name: 'User'
  validates :owner, presence: true

  validates :subdomain, presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: /\A[\w\-]+\Z/i, message: 'contains invalid characters' },
    exclusion: { in: RESTRICTED_SUBDOMAINS, message: 'restricted' }

  accepts_nested_attributes_for :owner
  before_validation :downcase_subdomain
  has_settings :sales_receipt_default_customer, :sales_receipt_deposit_to_account, :classify_shipping,
    :classify_sale_tax, :classify_promotion_shipping, :classify_shipping_sales_tax,
    :classify_fba_gift_wrap, :classify_balance_adjustment, :classify_gift_wrap_tax, :classify_unknown,
    :sales_receipt_income_account, :expense_bank_account, :expense_customer, :discount_item, :cost_of_goods_sold_account,
    :expense_unknown, :amazon_commission, :refund_commission_total,  :fba_per_order_fulfillment_fee, :fba_per_unit_fulfillment_fee,
    :fba_weight_based_fee, :sales_tax_service_fee, :inbound_transportation_fee, :payable_to_amazon, :storage_fees, :shipping_chargeback,
    :shipping_chargeback_refund, :warehouse_damage, :warehouse_damage_exception, :warehouse_lost_manual,
    :fba_customer_return_per_order_fee, :fba_customer_return_per_unit_fee, :fba_customer_return_weight_based_fee, :gift_wrap_charge_back,
    :disposal_fee, :reversal_reimbursement, :cs_error_items, :removal_complete, :default_location_for_amazon,
    :storage_renewal_billing, :fba_transportation_fee

  def inactive?
    active == false
  end

  def save_with_payment(plan, stripe_token, stripe_email)
    if valid?
      customer = Stripe::Customer.create(
        source: stripe_token,
        email: stripe_email
      )
      subscription = Stripe::Subscription.create(
        customer: customer.id,
        trial_period_days: plan.trial_period_days,
        plan: plan.stripe_id
      )
      Apartment::Tenant.create(self.subdomain)
      Apartment::Tenant.switch!(self.subdomain)
      self.sub_token = subscription.id
      user = self.owner
      user.stripe_customer_id = customer.id
      user.save
      self.save
    end
  rescue Stripe::StripeError => e
    errors.add :base, e.json_body[:error][:message]
    false
  end

  def reactivate_account(plan, stripe_token)
    if valid?
      user = self.owner
      customer = Stripe::Customer.retrieve(user.stripe_customer_id)
      customer.source = stripe_token
      customer.save
      subscription = Stripe::Subscription.create(
        customer: customer.id,
        plan: plan.stripe_id
      )
      self.sub_token = subscription.id
      self.active = true
      self.save
    end
  rescue Stripe::StripeError => e
    errors.add :base, e.json_body[:error][:message]
    false
  end

  def update_account(current_account, stripe_token)
    if valid?
      customer = Stripe::Customer.retrieve(current_account.owner.stripe_customer_id)
      customer.source = stripe_token
      customer.save
      self.save
    end
  rescue Stripe::StripeError => e
    errors.add :base, e.json_body[:error][:message]
    false
  end

  private

  def downcase_subdomain
    self.subdomain = subdomain.try(:downcase)
  end
end

