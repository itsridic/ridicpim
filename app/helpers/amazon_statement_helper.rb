module AmazonStatementHelper
  def show_status(statement)
    if statement.status == 'NOT_PROCESSED'
      link_to(statement.status, statement, class: "label success-color-dark")
    else
      link_to(statement.status, statement, class: "label info-color-dark")
    end
  end
end