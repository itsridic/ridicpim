class CancellationsController < ApplicationController
  before_action :authenticate_user!

  def new
    @cancellation = Cancellation.new
  end

  def create
    @cancellation = Cancellation.new(cancellation_params)
    if @cancellation.save
      subscription = Stripe::Subscription.retrieve(current_account.sub_token)
      subscription.delete
      current_account.active = false
      current_account.save
      redirect_to root_path, notice: "Your account has successfully been cancelled.  If this was a mistake, please contact info@itsridic.com"
    else
      render :new
    end
  end

  private

  def cancellation_params
    params.require(:cancellation).permit(:reason)
  end
end
