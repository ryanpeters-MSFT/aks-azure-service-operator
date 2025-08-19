# Azure Service Operator (ASO) for Kubernetes

Azure Service Operator (ASO) is an open-source Kubernetes operator that enables users to provision and manage a wide range of Azure resources directly within Kubernetes clusters using familiar tools like **kubectl** and YAML manifests. It acts as a bridge between Kubernetes and Azure, allowing developers to define Azure services as custom resource definitions (CRDs) and handle their lifecycle through the Kubernetes control loop, without needing separate infrastructure tools.

The key benefits of ASO include streamlined workflows by unifying application and infrastructure management in a single declarative model, enabling self-provisioning for developers and reducing the need for context-switching between tools. It also supports automated reconciliation for eventual consistency, enhances security through integrations like Azure Key Vault, and facilitates GitOps practices, making it ideal for Kubernetes-native environments.

## Quickstart

> **NOTE: This example deploys ALL CRDs possible for provisioning Azure resources, and this amount of CRDs can overwhelm the Free AKS tier. As a result, a Standard tier AKS cluster is deployed for this example.**

Invoke [setup.ps1](./setup.ps1) to create the resource group, AKS cluster (with Workload Identity enabled), install `cert-manager` and the ASO operator through Helm. 

```powershell
# invoke setup
.\setup.ps1
```

Once the cluster is created, you may deploy some sample Azure resources.

```powershell
# create a resource group
kubectl apply -f .\resources\resourcegroup.yaml

# create a basic storage account
kubectl apply -f .\resources\storageaccount.yaml

# create a vnet
kubectl apply -f .\resources\virtualnetwork.yaml
```

## Links
- [Azure Service Operator v2](https://azure.github.io/azure-service-operator/)
- [azure-service-operator](https://github.com/Azure/azure-service-operator)
- [azure-service-operator-samples](https://github.com/Azure-Samples/azure-service-operator-samples/tree/master)