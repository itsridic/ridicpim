module AmazonStatementHelper
  def show_status(statement)
    if statement.status == 'NOT_PROCESSED'
      link_to(statement.status, statement, class: "btn btn-sm success-color-dark")
    else
      link_to(statement.status, '#', class: "btn btn-sm info-color-dark")
    end
  end
end