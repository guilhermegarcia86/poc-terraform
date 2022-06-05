Provisionamento de infraestrutura na **AWS** utilizando **Terraform**.

Este projeto irá criar uma **VPC** e um serviço **EKS** na **AWS**.

## :rocket: Technology

<div align="center">

  ![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
  ![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)

</div>

## Instalação

Necessário ter instalado na máquina o *cli* do [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli), também necessário ter *cli* da [aws](https://docs.aws.amazon.com/pt_br/cli/latest/userguide/getting-started-install.html), para as configurações do **EKS** também é necessário ter o [aws-iam-authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html) instalado e por fim o [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)

*Opcional ter um bucket S3, caso não queira essa opção é necessário alterar o arquivo providers.tf na raiz do projeto /aws e remover o objeto backend que será gerado localmente o arquivo terraform.tfstate

## Rodar

Ir para o diretório:
```bash
cd /aws
```

Para inicializar o **terraform**:
```bash
terraform init
```

Para configurar as variáveis pode-se criar o arquivo **terraform.tfvars** ou passar as informações das variáveis no momento em que for executar os próximos comandos.

Para verificar o que será executado pelo **terraform**:
```bash
terraform plan
```

Para que o **terraform** execute o provisionamento da infraestrutura:
```bash
terraform apply --auto-approve
```

Após a criação da infraestrutura na **AWS** para acessar o **Kubernetes** é necessário configurar o **kubectl**:
```bash
cp kubeconfig ~/.kube/config
```

E para confirmar podemos rodar qualquer comando por linha de comando, ex:
```bash
kubectl get services                          # Listar todos os serviços do namespace
```

Para destruir a infra criada:
```bash
terraform apply -destroy --auto-approve
```
