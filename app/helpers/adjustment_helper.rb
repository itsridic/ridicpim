module AdjustmentHelper
  def adjustment_location(adjustment)
    if adjustment.location.nil?
      ""
    else
      adjustment.location.name
    end
  end
end
