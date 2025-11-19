targetScope = 'subscription'

param BudgetName string
param Amount int
param TimeGrain string = 'Monthly'
param StartDate string
param ContactEmails array
param Category string = 'Cost'

resource budget 'Microsoft.Consumption/budgets@2023-11-01' = {
  name: BudgetName
  properties: {
    category: Category
    amount: Amount
    timeGrain: TimeGrain
    timePeriod: {
      startDate: StartDate
    }
    notifications: {
      Notification80: {
        enabled: true
        operator: 'GreaterThan'
        threshold: 80
        contactEmails: ContactEmails
        thresholdType: 'Actual'
      }
      Notification100: {
        enabled: true
        operator: 'GreaterThan'
        threshold: 100
        contactEmails: ContactEmails
        thresholdType: 'Actual'
      }
      Forecast110: {
        enabled: true
        operator: 'GreaterThan'
        threshold: 110
        contactEmails: ContactEmails
        thresholdType: 'Forecasted'
      }
    }
  }
}

output BudgetId string = budget.id
output BudgetName string = budget.name
