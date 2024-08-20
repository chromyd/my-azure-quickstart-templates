TEMPLATE=$1

az deployment group create --resource-group azureml-rg-aipd218 --template-file {$TEMPLATE:-main.bicep}