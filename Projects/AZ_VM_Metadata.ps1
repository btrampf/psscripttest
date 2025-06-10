#AzureCLI

#Login Creates a "hidden" background prompt that asks for credentials
    #login to azure with cli
az login

#lists current subcription for cli commands
az account show

#lists all subscriptions in your account
az account list

#set a subscription to be active subscription
az account set --subscription mysubscription

#list all vms
az vm list


#PowerShell

#Login Creates a "hidden" background prompt that asks for credentials
    #Connect-AzAccount sets your default subscription for your session
Connect-AzAccount

#lists all your subscriptions in your account
Get-AzSubscription

#change Azure Subscriptions
set-AzContext -subscription PS_SOC2_Master

#List Resource Groups in your subscription
get-azresourcegroup

#List VMs in your Subscription
Get-AzVM