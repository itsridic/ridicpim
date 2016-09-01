Paloma.controller('QboAccounts', {
  index: function() {
    $(document).ready(function() {

      $(".spinner").hide();

      $(".modal").on("shown.bs.modal", function(e) {
        $(document).off(".fetchAccounts")
        $(':input','#new_qbo_account').not(':button, :submit, :reset, :hidden').val('').removeAttr('checked').removeAttr('selected');
        $('form[data-validate]').enableClientSideValidations();
      });

      $("#fetch-accounts").click(function() {
        $(document).on("ajaxStart.fetchAccounts", function () {
            $('.spinner').show();
        });
        $(document).on("ajaxStop.fetchAccounts", function () {
            $('.spinner').hide();
            location.reload();
        });      
      });

      $("#qbo_account_account_type").on("change", function(e) {
        var selectedValue = e.target.value;
        switch(selectedValue) {
          case "Bank":
            var newOptions = ["CashOnHand", "Checking", "MoneyMarket", "RentsHeldInTrust", "Savings", "TrustAccounts"];
            break;
          case "Other Current Asset":
            var newOptions = ["AllowanceForBadDebts", "DevelopmentCosts", "EmployeeCashAdvances", "OtherCurrentAssets", "Inventory", "Investment_MortgageRealEstateLoans", "Investment_Other", "Investment_TaxExemptSecurities", "Investment_USGovernmentObligations", "LoansToOfficers", "LoansToOthers", "LoansToStockholders", "PrepaidExpenses", "Retainage", "UndepositedFunds"];
            break;
          case "Fixed Asset":
            var newOptions = ["AccumulatedDepletion", "AccumulatedDepreciation", "DepletableAssets", "FurnitureAndFixtures", "Land", "LeaseholdImprovements", "OtherFixedAssets", "AccumulatedAmortization", "Buildings", "IntangibleAssets", "MachineryAndEquipment", "Vehicles"];
            break;
          case "Other Asset":
            var newOptions = ["LeaseBuyout", "OtherLongTermAssets", "SecurityDeposits", "AccumulatedAmortizationOfOtherAssets", "Goodwill", "Licenses", "OrganizationalCosts"];
            break;
          case "Accounts Receivable":
            var newOptions = ["AccountsReceivable"];
            break;
          case "Equity":
            var newOptions = ["OpeningBalanceEquity", "PartnersEquity", "RetainedEarnings", "AccumulatedAdjustment", "OwnersEquity", "PaidInCapitalOrSurplus", "PartnerContributions", "PartnerDistributions", "PreferredStock", "CommonStock", "TreasuryStock"];
            break;
          case "Expense":
            var newOptions = ["AdvertisingPromotional", "BadDebts", "BankCharges", "CharitableContributions", "Entertainment", "EntertainmentMeals", "EquipmentRental", "FinanceCosts", "GlobalTaxExpense", "Insurance", "InterestPaid", "LegalProfessionalFees", "OfficeGeneralAdministrativeExpenses", "OtherMiscellaneousServiceCost", "PromotionalMeals", "RentOrLeaseOfBuildings", "RepairMaintenance", "ShippingFreightDelivery", "SuppliesMaterials", "Travel", "TravelMeals", "Utilities", "Auto", "CostOfLabor", "DuesSubscriptions", "PayrollExpenses", "TaxesPaid", "UnappliedCashBillPaymentExpense "];
            break;
          case "Other Expense":
            var newOptions = ["Depreciation", "ExchangeGainOrLoss", "OtherMiscellaneousExpense", "PenaltiesSettlements", "Amortization"];
            break;
          case "Cost Of Goods Sold":
            var newOptions = ["EquipmentRentalCos", "OtherCostsOfServiceCos", "ShippingFreightDeliveryCos", "SuppliesMaterialsCogs", "CostOfLaborCos"];
            break;
          case "Accounts Payable":
            var newOptions = ["AccountsPayable"];
            break;
          case "Credit Card":
            var newOptions = ["CreditCard"];
            break;
          case "Long Term Liability":
            var newOptions = ["NotesPayable", "OtherLongTermLiabilities", "ShareholderNotesPayable"];
            break;
          case "Other Current Liability":
            var newOptions = ["DirectDepositPayable", "LineOfCredit", "LoanPayable", "GlobalTaxPayable", "GlobalTaxSuspense", "OtherCurrentLiabilities", "PayrollClearing", "PayrollTaxPayable", "PrepaidExpensesPayable", "RentsInTrustLiability", "TrustAccountsLiabilities", "FederalIncomeTaxPayable", "InsurancePayable", "SalesTaxPayable", "StateLocalIncomeTaxPayable"];
            break;
          case "Income":
            var newOptions = ["NonProfitIncome", "OtherPrimaryIncome", "SalesOfProductIncome", "ServiceFeeIncome", "DiscountsRefundsGiven", "UnappliedCashPaymentIncome"];
            break;
          case "Other Income":
            var newOptions = ["DividendIncome", "InterestEarned", "OtherInvestmentIncome", "OtherMiscellaneousIncome", "TaxExemptInterest"];
            break;
        }
        var $el = $("#qbo_account_account_sub_type");
        $el.empty();
        $.each(newOptions, function(key, value) {
          $el.append($("<option></option>")
             .attr("value", value).text(value));
        });
      });
    });
  }
});