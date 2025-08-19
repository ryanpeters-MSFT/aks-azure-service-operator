$group = "rg-aks-aso"
$cluster = "asocluster"
$federatedName = "aso-federated-credential" # id used for federated credential
$azureManagedIdentity = "ryan-workload" # workload managed identity in Azure
$namespace = "azureserviceoperator-system" # kubernetes namespace of the service account
$serviceAccountName = "azureserviceoperator-default" # kubernetes service account name

$account = az account show | ConvertFrom-Json

$subscription = $account.id
$tenant = $account.tenantId

# create resource group
az group create -n $group -l eastus2

# # create a cluster
az aks create -n $cluster -g $group `
    -c 1 `
    --enable-oidc-issuer `
    --enable-workload-identity

# # authenticate to the cluster
az aks get-credentials -n $cluster -g $group --overwrite-existing

# get OIDC issuer
$oidcIssuer = az aks show -n $cluster -g $group --query oidcIssuerProfile.issuerUrl -o tsv

# create the azure managed identity for workload identity
$clientId = az identity create -n $azureManagedIdentity -g $group --query clientId -o tsv

# assign contributor role to identity
az role assignment create `
    --role Contributor `
    --assignee $clientId `
    --scope /subscriptions/$subscription/

# create the federated identity
az identity federated-credential create `
    --name $federatedName `
    -g $group `
    --identity-name $azureManagedIdentity  `
    --subject system:serviceaccount:$($namespace):$($serviceAccountName) `
    --issuer $oidcIssuer `
    --audiences "api://AzureADTokenExchange"

# install certmanager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.18.2/cert-manager.yaml

# wait for cert-manager to be ready
Start-Sleep -Seconds 30  
kubectl wait --for=condition=Available deployment --all -n cert-manager --timeout=300s


# $principal = az ad sp create-for-rbac `
#     -n azure-service-operator `
#     --role contributor `
#     --scopes /subscriptions/$subscription | ConvertFrom-Json

# $clientId = $principal.appId
# $secret = $principal.password

helm repo add aso2 https://raw.githubusercontent.com/Azure/azure-service-operator/main/v2/charts

helm upgrade --install aso2 aso2/azure-service-operator `
    --create-namespace `
    --namespace=$namespace `
    --set azureSubscriptionID=$subscription `
    --set azureTenantID=$tenant `
    --set azureClientID=$clientId `
    --set useWorkloadIdentityAuth=true `
    --set crdPattern='*'
    #--set crdPattern='resources.azure.com/*;containerservice.azure.com/*;keyvault.azure.com/*;managedidentity.azure.com/*;eventhub.azure.com/*'