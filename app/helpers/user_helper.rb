module UserHelper
  def user_status(user)
    if current_account.owner == user || user.invitation_accepted?
      content_tag(:i, '', class: 'fa fa-check color-success') 
    else
      'Invitation Pending'
    end
  end
end