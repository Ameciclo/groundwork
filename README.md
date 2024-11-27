# My NGO Infrastructure

This repository contains Terraform configurations for managing the infrastructure of our NGO. The infrastructure is designed to be modular and scalable.

## Getting Started

1. Install [Terraform](https://www.terraform.io/downloads.html).
2. Clone this repository.
3. Configure AWS credentials using the AWS CLI or environment variables.
4. Run the following commands:
   ]133;A;cl=m;aid=1775529Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\]133;D;0;aid=1775529]133;A;cl=m;aid=1775529Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\[0m[1mInitializing the backend...[0m
[0m[1mInitializing modules...[0m
- network in
]133;D;1;aid=1775529]133;A;cl=m;aid=1775529Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\]133;D;0;aid=1775529]133;A;cl=m;aid=1775529Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\]133;D;0;aid=1775529]133;A;cl=m;aid=1775529Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\]133;D;0;aid=1775529]133;A;cl=m;aid=1775529Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\[0m[1mInitializing the backend...[0m
[0m[1mInitializing modules...[0m
- network in modules/network
]133;D;1;aid=1775529]133;A;cl=m;aid=1775529Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\]133;D;0;aid=1775529]133;A;cl=m;aid=1775529Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\Pacote                   Arch   Versão Repositório    Tamanho
Instalando:
 packages-microsoft-prod noarch 1.0-1  @commandline 204.0   B

Sumário da Transação:
 Instalando:         1 pacote

]133;D;0;aid=1775529]133;A;cl=m;aid=1775529Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\Pacote     Arch   Versão          Repositório                   Tamanho
Instalando:
 azure-cli x86_64 2.67.0-1.el8    packages-microsoft-com-prod 463.6 MiB
Instalando dependências:
 python3.9 x86_64 3.9.20-1.fc41   fedora                       90.2 MiB
 tk        x86_64 1:8.6.14-2.fc41 fedora                        3.6 MiB

Sumário da Transação:
 Instalando:         3 pacotes

]133;D;0;aid=1775529]133;A;cl=m;aid=1775529Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\azure-cli                         2.67.0

core                              2.67.0
telemetry                          1.1.0

Dependencies:
msal                              1.31.0
azure-mgmt-resource               23.1.1

Python location '/usr/bin/python3.9'
Extensions directory '/home/plpbs/.azure/cliextensions'

Python (Linux) 3.9.20 (main, Sep  9 2024, 00:00:00) 
[GCC 14.2.1 20240801 (Red Hat 14.2.1-1)]

Legal docs and information: aka.ms/AzureCliLegal


Your CLI is up-to-date.
]133;D;0;aid=1775529]133;A;cl=m;aid=1775529Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\[
  {
    "cloudName": "AzureCloud",
    "homeTenantId": "f95855cd-e7ae-42a4-9b0a-f2210e4b20a1",
    "id": "c3f6fc46-db16-431a-9f38-ce66a01eca0b",
    "isDefault": true,
    "managedByTenants": [],
    "name": "Azure subscription 1",
    "state": "Enabled",
    "tenantDefaultDomain": "ameciclo.onmicrosoft.com",
    "tenantDisplayName": "Ameciclo - Associação Metropolitana de Ciclistas do Recife",
    "tenantId": "f95855cd-e7ae-42a4-9b0a-f2210e4b20a1",
    "user": {
      "name": "tecnologia@ameciclo.onmicrosoft.com",
      "type": "user"
    }
  }
]
]133;D;0;aid=1775529]133;A;cl=m;aid=1775529Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\[0m[1mInitializing the backend...[0m
[0m[1mInitializing modules...[0m
]133;D;1;aid=1775529]133;A;cl=m;aid=1775529Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\environments
main.tf
modules
outputs.tf
README.md
variables.tf
]133;D;0;aid=1775529]133;A;cl=m;aid=1775529Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\       [38;2;0;0;0m▄[38;2;0;0;0m[48;2;65;65;65m▀[0m[38;2;0;0;0m[48;2;129;119;55m▀[0m[38;2;0;0;0m[48;2;0;0;0m▀[0m[38;2;0;0;0m▄[38;2;0;0;0m▄           
      [38;2;0;0;0m[48;2;0;0;0m▀[0m[38;2;129;119;55m[48;2;197;189;173m▀[0m[38;2;255;255;255m[48;2;0;0;0m▀[0m[38;2;129;119;55m[48;2;65;65;65m▀[0m[38;2;65;65;65m[48;2;162;150;83m▀[0m[38;2;162;150;83m[48;2;255;255;255m▀[0m[38;2;162;150;83m[48;2;197;189;173m▀[0m[38;2;0;0;0m[48;2;162;150;83m▀[0m[38;2;0;0;0m▄         
      [38;2;0;0;0m▀[38;2;129;119;55m[48;2;0;0;0m▀[0m[38;2;197;189;173m[48;2;129;119;55m▀[0m[38;2;65;65;65m[48;2;129;119;55m▀[0m[38;2;197;189;173m[48;2;162;150;83m▀[0m[38;2;0;0;0m[48;2;255;255;255m▀[0m[38;2;255;255;255m[48;2;197;189;173m▀[0m[38;2;162;150;83m[48;2;129;119;55m▀[0m[38;2;0;0;0m[48;2;65;65;65m▀[0m[38;2;0;0;0m▄[38;2;0;0;0m[48;2;162;150;83m▀[0m[38;2;0;0;0m[48;2;162;150;83m▀[0m[38;2;0;0;0m[48;2;162;150;83m▀[0m[38;2;0;0;0m▄    
  [38;2;0;0;0m▄[38;2;0;0;0m▄[38;2;0;0;0m[48;2;230;214;140m▀[0m[38;2;0;0;0m[48;2;230;214;140m▀[0m[38;2;0;0;0m[48;2;230;214;140m▀[0m[38;2;65;65;65m[48;2;230;214;140m▀[0m[38;2;65;65;65m[48;2;230;214;140m▀[0m[38;2;162;150;83m[48;2;65;65;65m▀[0m[38;2;162;150;83m[48;2;65;65;65m▀[0m[38;2;162;150;83m[48;2;230;214;140m▀[0m[38;2;129;119;55m[48;2;230;214;140m▀[0m[38;2;162;150;83m[48;2;65;65;65m▀[0m[38;2;162;150;83m[48;2;65;65;65m▀[0m[38;2;65;65;65m[48;2;230;214;140m▀[0m[38;2;129;119;55m[48;2;230;214;140m▀[0m[38;2;129;119;55m[48;2;230;214;140m▀[0m[38;2;129;119;55m[48;2;162;150;83m▀[0m[38;2;196;182;111m[48;2;162;150;83m▀[0m[38;2;0;0;0m[48;2;196;182;111m▀[0m[38;2;0;0;0m▄[38;2;0;0;0m[48;2;196;182;111m▀[0m[38;2;0;0;0m▄
[38;2;0;0;0m▄[38;2;0;0;0m[48;2;65;65;65m▀[0m[38;2;230;214;140m[48;2;162;150;83m▀[0m[38;2;230;214;140m[48;2;230;214;140m▀[0m[38;2;230;214;140m[48;2;230;214;140m▀[0m[38;2;230;214;140m[48;2;230;214;140m▀[0m[38;2;230;214;140m[48;2;230;214;140m▀[0m[38;2;230;214;140m[48;2;230;214;140m▀[0m[38;2;230;214;140m[48;2;230;214;140m▀[0m[38;2;230;214;140m[48;2;230;214;140m▀[0m[38;2;230;214;140m[48;2;230;214;140m▀[0m[38;2;65;65;65m[48;2;230;214;140m▀[0m[38;2;230;214;140m[48;2;230;214;140m▀[0m[38;2;65;65;65m[48;2;230;214;140m▀[0m[38;2;196;182;111m[48;2;65;65;65m▀[0m[38;2;196;182;111m[48;2;196;182;111m▀[0m[38;2;230;214;140m[48;2;196;182;111m▀[0m[38;2;162;150;83m[48;2;162;150;83m▀[0m[38;2;162;150;83m[48;2;162;150;83m▀[0m[38;2;162;150;83m[48;2;230;214;140m▀[0m[38;2;162;150;83m[48;2;162;150;83m▀[0m[38;2;65;65;65m[48;2;230;214;140m▀[0m[38;2;196;182;111m[48;2;0;0;0m▀[0m[38;2;0;0;0m▀
[38;2;0;0;0m[48;2;0;0;0m▀[0m[38;2;65;65;65m[48;2;65;65;65m▀[0m[38;2;162;150;83m[48;2;162;150;83m▀[0m[38;2;230;214;140m[48;2;230;214;140m▀[0m[38;2;230;214;140m[48;2;230;214;140m▀[0m[38;2;230;214;140m[48;2;162;150;83m▀[0m[38;2;162;150;83m[48;2;65;65;65m▀[0m[38;2;162;150;83m[48;2;65;65;65m▀[0m[38;2;162;150;83m[48;2;162;150;83m▀[0m[38;2;230;214;140m[48;2;162;150;83m▀[0m[38;2;230;214;140m[48;2;230;214;140m▀[0m[38;2;230;214;140m[48;2;230;214;140m▀[0m[38;2;230;214;140m[48;2;230;214;140m▀[0m[38;2;230;214;140m[48;2;230;214;140m▀[0m[38;2;65;65;65m[48;2;162;150;83m▀[0m[38;2;196;182;111m[48;2;162;150;83m▀[0m[38;2;196;182;111m[48;2;162;150;83m▀[0m[38;2;196;182;111m[48;2;196;182;111m▀[0m[38;2;230;214;140m[48;2;196;182;111m▀[0m[38;2;230;214;140m[48;2;230;214;140m▀[0m[38;2;230;214;140m[48;2;196;182;111m▀[0m[38;2;230;214;140m[48;2;196;182;111m▀[0m[38;2;0;0;0m[48;2;0;0;0m▀[0m 
[38;2;0;0;0m▀[38;2;162;150;83m[48;2;0;0;0m▀[0m[38;2;162;150;83m[48;2;230;214;140m▀[0m[38;2;230;214;140m[48;2;230;214;140m▀[0m[38;2;230;214;140m[48;2;230;214;140m▀[0m[38;2;65;65;65m[48;2;65;65;65m▀[0m[38;2;65;65;65m[48;2;65;65;65m▀[0m[38;2;65;65;65m[48;2;65;65;65m▀[0m[38;2;65;65;65m[48;2;65;65;65m▀[0m[38;2;162;150;83m[48;2;162;150;83m▀[0m[38;2;230;214;140m[48;2;230;214;140m▀[0m[38;2;230;214;140m[48;2;230;214;140m▀[0m[38;2;230;214;140m[48;2;230;214;140m▀[0m[38;2;230;214;140m[48;2;196;182;111m▀[0m[38;2;162;150;83m[48;2;196;182;111m▀[0m[38;2;162;150;83m[48;2;230;214;140m▀[0m[38;2;230;214;140m[48;2;230;214;140m▀[0m[38;2;196;182;111m[48;2;65;65;65m▀[0m[38;2;65;65;65m[48;2;162;150;83m▀[0m[38;2;162;150;83m[48;2;162;150;83m▀[0m[38;2;196;182;111m[48;2;230;214;140m▀[0m[38;2;196;182;111m[48;2;0;0;0m▀[0m[38;2;0;0;0m▀ 
  [38;2;0;0;0m▀[38;2;230;214;140m[48;2;0;0;0m▀[0m[38;2;230;214;140m[48;2;0;0;0m▀[0m[38;2;230;214;140m[48;2;230;214;140m▀[0m[38;2;65;65;65m[48;2;230;214;140m▀[0m[38;2;65;65;65m[48;2;230;214;140m▀[0m[38;2;162;150;83m[48;2;230;214;140m▀[0m[38;2;230;214;140m[48;2;230;214;140m▀[0m[38;2;230;214;140m[48;2;230;214;140m▀[0m[38;2;230;214;140m[48;2;0;0;0m▀[0m[38;2;230;214;140m[48;2;0;0;0m▀[0m[38;2;65;65;65m[48;2;230;214;140m▀[0m[38;2;196;182;111m[48;2;230;214;140m▀[0m[38;2;196;182;111m[48;2;230;214;140m▀[0m[38;2;230;214;140m[48;2;230;214;140m▀[0m[38;2;0;0;0m[48;2;0;0;0m▀[0m[38;2;0;0;0m▀[38;2;230;214;140m[48;2;0;0;0m▀[0m[38;2;230;214;140m[48;2;0;0;0m▀[0m[38;2;0;0;0m▀  
     [38;2;0;0;0m▀[38;2;0;0;0m▀[38;2;0;0;0m▀[38;2;0;0;0m▀[38;2;0;0;0m▀[38;2;0;0;0m▀ [38;2;0;0;0m▀[38;2;230;214;140m[48;2;0;0;0m▀[0m[38;2;162;150;83m[48;2;0;0;0m▀[0m[38;2;255;255;255m[48;2;0;0;0m▀[0m[38;2;0;0;0m▀       
[0m
]133;A;cl=m;aid=2102116Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\k..lo/groundwork\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork\[?1h=]133;D;130;aid=2102116]133;A;cl=m;aid=2102116Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\k..lo/groundwork\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork\[?1h=]133;D;130;aid=1775529]133;A;cl=m;aid=1775529Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\        [38;2;0;0;0m▄[38;2;0;0;0m[48;2;203;191;191m▀[0m[38;2;0;0;0m[48;2;203;191;191m▀[0m[38;2;0;0;0m▄[38;2;0;0;0m▄[38;2;0;0;0m▄[38;2;0;0;0m▄[38;2;0;0;0m▄ [38;2;0;0;0m▄[38;2;0;0;0m▄ 
        [38;2;0;0;0m▀[38;2;203;191;191m[48;2;0;0;0m▀[0m[38;2;65;65;65m[48;2;255;255;255m▀[0m[38;2;203;191;191m[48;2;255;255;255m▀[0m[38;2;255;255;255m[48;2;255;255;255m▀[0m[38;2;255;255;255m[48;2;255;255;255m▀[0m[38;2;203;191;191m[48;2;255;255;255m▀[0m[38;2;65;65;65m[48;2;255;255;255m▀[0m[38;2;0;0;0m[48;2;255;255;255m▀[0m[38;2;203;191;191m[48;2;255;255;255m▀[0m[38;2;255;255;255m[48;2;203;191;191m▀[0m[38;2;0;0;0m[48;2;0;0;0m▀[0m
        [38;2;0;0;0m[48;2;0;0;0m▀[0m[38;2;203;191;191m[48;2;255;255;255m▀[0m[38;2;255;255;255m[48;2;255;255;255m▀[0m[38;2;255;255;255m[48;2;255;255;255m▀[0m[38;2;255;255;255m[48;2;203;191;191m▀[0m[38;2;203;191;191m[48;2;203;191;191m▀[0m[38;2;203;191;191m[48;2;65;65;65m▀[0m[38;2;255;255;255m[48;2;65;65;65m▀[0m[38;2;255;255;255m[48;2;203;191;191m▀[0m[38;2;203;191;191m[48;2;203;191;191m▀[0m[38;2;0;0;0m[48;2;0;0;0m▀[0m 
       [38;2;0;0;0m▄[38;2;0;0;0m[48;2;255;255;255m▀[0m[38;2;255;255;255m[48;2;255;255;255m▀[0m[38;2;255;255;255m[48;2;255;255;255m▀[0m[38;2;255;255;255m[48;2;255;255;255m▀[0m[38;2;203;191;191m[48;2;203;191;191m▀[0m[38;2;65;65;65m[48;2;99;121;67m▀[0m[38;2;99;121;67m[48;2;0;0;0m▀[0m[38;2;99;121;67m[48;2;255;255;255m▀[0m[38;2;65;65;65m[48;2;124;148;90m▀[0m[38;2;203;191;191m[48;2;203;191;191m▀[0m[38;2;0;0;0m[48;2;203;191;191m▀[0m[38;2;0;0;0m▄
      [38;2;0;0;0m[48;2;0;0;0m▀[0m[38;2;255;255;255m[48;2;255;255;255m▀[0m[38;2;255;255;255m[48;2;255;255;255m▀[0m[38;2;255;255;255m[48;2;203;191;191m▀[0m[38;2;255;255;255m[48;2;0;0;0m▀[0m[38;2;255;255;255m[48;2;203;191;191m▀[0m[38;2;65;65;65m[48;2;203;191;191m▀[0m[38;2;255;255;255m[48;2;65;65;65m▀[0m[38;2;0;0;0m[48;2;124;148;90m▀[0m[38;2;255;255;255m[48;2;203;191;191m▀[0m[38;2;65;65;65m[48;2;203;191;191m▀[0m[38;2;203;191;191m[48;2;203;191;191m▀[0m[38;2;203;191;191m[48;2;65;65;65m▀[0m[38;2;0;0;0m[48;2;0;0;0m▀[0m
      [38;2;0;0;0m▀[38;2;203;191;191m[48;2;0;0;0m▀[0m[38;2;255;255;255m[48;2;203;191;191m▀[0m[38;2;65;65;65m[48;2;203;191;191m▀[0m[38;2;203;191;191m[48;2;203;191;191m▀[0m[38;2;203;191;191m[48;2;203;191;191m▀[0m[38;2;203;191;191m[48;2;65;65;65m▀[0m[38;2;203;191;191m[48;2;65;65;65m▀[0m[38;2;203;191;191m[48;2;65;65;65m▀[0m[38;2;65;65;65m[48;2;124;148;90m▀[0m[38;2;203;191;191m[48;2;65;65;65m▀[0m[38;2;203;191;191m[48;2;0;0;0m▀[0m[38;2;0;0;0m▀ 
 [38;2;0;0;0m▄[38;2;0;0;0m▄  [38;2;0;0;0m▄[38;2;0;0;0m▄[38;2;0;0;0m[48;2;124;148;90m▀[0m[38;2;65;65;65m[48;2;65;65;65m▀[0m[38;2;203;191;191m[48;2;65;65;65m▀[0m[38;2;65;65;65m[48;2;228;214;186m▀[0m[38;2;65;65;65m[48;2;228;214;186m▀[0m[38;2;228;214;186m[48;2;228;214;186m▀[0m[38;2;124;148;90m[48;2;228;214;186m▀[0m[38;2;124;148;90m[48;2;124;148;90m▀[0m[38;2;124;148;90m[48;2;65;65;65m▀[0m[38;2;124;148;90m[48;2;124;148;90m▀[0m[38;2;124;148;90m[48;2;124;148;90m▀[0m[38;2;0;0;0m[48;2;124;148;90m▀[0m[38;2;0;0;0m▄
[38;2;0;0;0m[48;2;0;0;0m▀[0m[38;2;203;191;191m[48;2;255;255;255m▀[0m[38;2;255;255;255m[48;2;255;255;255m▀[0m[38;2;0;0;0m[48;2;255;255;255m▀[0m[38;2;0;0;0m[48;2;255;255;255m▀[0m[38;2;203;191;191m[48;2;203;191;191m▀[0m[38;2;255;255;255m[48;2;0;0;0m▀[0m[38;2;65;65;65m[48;2;0;0;0m▀[0m[38;2;99;121;67m[48;2;65;65;65m▀[0m[38;2;65;65;65m[48;2;99;121;67m▀[0m[38;2;228;214;186m[48;2;65;65;65m▀[0m[38;2;228;214;186m[48;2;228;214;186m▀[0m[38;2;228;214;186m[48;2;228;214;186m▀[0m[38;2;65;65;65m[48;2;65;65;65m▀[0m[38;2;124;148;90m[48;2;124;148;90m▀[0m[38;2;124;148;90m[48;2;124;148;90m▀[0m[38;2;65;65;65m[48;2;124;148;90m▀[0m[38;2;65;65;65m[48;2;99;121;67m▀[0m[38;2;124;148;90m[48;2;0;0;0m▀[0m[38;2;0;0;0m▀
 [38;2;0;0;0m[48;2;0;0;0m▀[0m[38;2;255;255;255m[48;2;255;255;255m▀[0m[38;2;255;255;255m[48;2;203;191;191m▀[0m[38;2;0;0;0m[48;2;0;0;0m▀[0m[38;2;0;0;0m▀  [38;2;0;0;0m▀[38;2;0;0;0m▀[38;2;0;0;0m▀[38;2;65;65;65m▀[38;2;228;214;186m[48;2;0;0;0m▀[0m[38;2;228;214;186m[48;2;0;0;0m▀[0m[38;2;65;65;65m[48;2;0;0;0m▀[0m[38;2;99;121;67m[48;2;255;255;255m▀[0m[38;2;99;121;67m[48;2;255;255;255m▀[0m[38;2;99;121;67m[48;2;0;0;0m▀[0m[38;2;0;0;0m▀ 
  [38;2;0;0;0m▀[38;2;0;0;0m▀           [38;2;0;0;0m▀[38;2;0;0;0m▀   
[0m
]133;A;cl=m;aid=2102645Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\k..lo/groundwork\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork\[?1h=]133;D;130;aid=2102645]133;A;cl=m;aid=2102645Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\k..lo/groundwork\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork\[?1h=[?1l>]133;C;Ptmux;]1337;SetUserVar=WEZTERM_PROG=dGVycmFmb3JtIHBsYW4=\kterraform\
Interrupt received.
Please wait for Terraform to exit or data loss may occur.
Gracefully shutting down...

Stopping operation...

[0m[1m[31mPlanning failed.[0m[1m Terraform encountered an error while generating this plan.[0m

[0m]133;D;1;aid=2102645]133;A;cl=m;aid=2102645Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\k..lo/groundwork\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork\[?1h=]133;D;130;aid=2102645]133;A;cl=m;aid=2102645Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\k..lo/groundwork\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork\[?1h=[?1l>]133;C;Ptmux;]1337;SetUserVar=WEZTERM_PROG=YXogbG9naW4=\kaz\[
  {
    "cloudName": "AzureCloud",
    "homeTenantId": "78fdb34b-6683-4eda-a072-33c297bd4908",
    "id": "c4ed1ad5-57e9-47c0-acb3-287bb631e0b6",
    "isDefault": false,
    "managedByTenants": [],
    "name": "Pago pelo Uso",
    "state": "Enabled",
    "tenantDefaultDomain": "iacapucagmailcom.onmicrosoft.com",
    "tenantDisplayName": "Diretório Padrão",
    "tenantId": "78fdb34b-6683-4eda-a072-33c297bd4908",
    "user": {
      "name": "iacapuca@gmail.com",
      "type": "user"
    }
  },
  {
    "cloudName": "AzureCloud",
    "homeTenantId": "f95855cd-e7ae-42a4-9b0a-f2210e4b20a1",
    "id": "c3f6fc46-db16-431a-9f38-ce66a01eca0b",
    "isDefault": true,
    "managedByTenants": [],
    "name": "Azure subscription 1",
    "state": "Enabled",
    "tenantDefaultDomain": "ameciclo.onmicrosoft.com",
    "tenantDisplayName": "Ameciclo - Associação Metropolitana de Ciclistas do Recife",
    "tenantId": "f95855cd-e7ae-42a4-9b0a-f2210e4b20a1",
    "user": {
      "name": "iacapuca@gmail.com",
      "type": "user"
    }
  }
]
]133;D;0;aid=2102645]133;A;cl=m;aid=2102645Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\k..lo/groundwork\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork\[?1h=[?1l>]133;C;Ptmux;]1337;SetUserVar=WEZTERM_PROG=dGVycmFmb3JtIGluaXQ=\kterraform\[0m[1mInitializing the backend...[0m
[0m[1mInitializing provider plugins...[0m
- Reusing previous version of hashicorp/azurerm from the dependency lock file
- Using previously-installed hashicorp/azurerm v3.117.0

[0m[1m[32mTerraform has been successfully initialized![0m[32m[0m
[0m[32m
You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.[0m
]133;D;0;aid=2102645]133;A;cl=m;aid=2102645Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\k..lo/groundwork\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork\[?1h=[?1l>]133;C;Ptmux;]1337;SetUserVar=WEZTERM_PROG=dGVycmFmb3JtIHBsYW4=\kterraform\
[0m[1m[31mPlanning failed.[0m[1m Terraform encountered an error while generating this plan.[0m

[0m]133;D;1;aid=2102645]133;A;cl=m;aid=2102645Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\k..lo/groundwork\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork\[?1h=[?1l>]133;C;Ptmux;]1337;SetUserVar=WEZTERM_PROG=YXogbG9naW4=\kaz\[
  {
    "cloudName": "AzureCloud",
    "homeTenantId": "78fdb34b-6683-4eda-a072-33c297bd4908",
    "id": "c4ed1ad5-57e9-47c0-acb3-287bb631e0b6",
    "isDefault": false,
    "managedByTenants": [],
    "name": "Pago pelo Uso",
    "state": "Enabled",
    "tenantDefaultDomain": "iacapucagmailcom.onmicrosoft.com",
    "tenantDisplayName": "Diretório Padrão",
    "tenantId": "78fdb34b-6683-4eda-a072-33c297bd4908",
    "user": {
      "name": "iacapuca@gmail.com",
      "type": "user"
    }
  },
  {
    "cloudName": "AzureCloud",
    "homeTenantId": "f95855cd-e7ae-42a4-9b0a-f2210e4b20a1",
    "id": "c3f6fc46-db16-431a-9f38-ce66a01eca0b",
    "isDefault": true,
    "managedByTenants": [],
    "name": "Azure subscription 1",
    "state": "Enabled",
    "tenantDefaultDomain": "ameciclo.onmicrosoft.com",
    "tenantDisplayName": "Ameciclo - Associação Metropolitana de Ciclistas do Recife",
    "tenantId": "f95855cd-e7ae-42a4-9b0a-f2210e4b20a1",
    "user": {
      "name": "iacapuca@gmail.com",
      "type": "user"
    }
  }
]
]133;D;0;aid=2102645]133;A;cl=m;aid=2102645Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\k..lo/groundwork\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork\[?1h=[?1l>]133;C;Ptmux;]1337;SetUserVar=WEZTERM_PROG=dGVycmFmb3JtIHBsYW4=\kterraform\
[0m[1m[31mPlanning failed.[0m[1m Terraform encountered an error while generating this plan.[0m

[0m]133;D;1;aid=2102645]133;A;cl=m;aid=2102645Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\k..lo/groundwork\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork\[?1h=[?1l>]133;C;Ptmux;]1337;SetUserVar=WEZTERM_PROG=dGVycmFmb3JtIHBsYW4=\kterraform\
[0m[1m[31mPlanning failed.[0m[1m Terraform encountered an error while generating this plan.[0m

[0m]133;D;1;aid=2102645]133;A;cl=m;aid=2102645Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\k..lo/groundwork\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork\[?1h=[?1l>]133;C;Ptmux;]1337;SetUserVar=WEZTERM_PROG=YXogbG9naW4=\kaz\[
  {
    "cloudName": "AzureCloud",
    "homeTenantId": "78fdb34b-6683-4eda-a072-33c297bd4908",
    "id": "c4ed1ad5-57e9-47c0-acb3-287bb631e0b6",
    "isDefault": false,
    "managedByTenants": [],
    "name": "Pago pelo Uso",
    "state": "Enabled",
    "tenantDefaultDomain": "iacapucagmailcom.onmicrosoft.com",
    "tenantDisplayName": "Diretório Padrão",
    "tenantId": "78fdb34b-6683-4eda-a072-33c297bd4908",
    "user": {
      "name": "iacapuca@gmail.com",
      "type": "user"
    }
  },
  {
    "cloudName": "AzureCloud",
    "homeTenantId": "f95855cd-e7ae-42a4-9b0a-f2210e4b20a1",
    "id": "c3f6fc46-db16-431a-9f38-ce66a01eca0b",
    "isDefault": true,
    "managedByTenants": [],
    "name": "Azure subscription 1",
    "state": "Enabled",
    "tenantDefaultDomain": "ameciclo.onmicrosoft.com",
    "tenantDisplayName": "Ameciclo - Associação Metropolitana de Ciclistas do Recife",
    "tenantId": "f95855cd-e7ae-42a4-9b0a-f2210e4b20a1",
    "user": {
      "name": "iacapuca@gmail.com",
      "type": "user"
    }
  }
]
]133;D;0;aid=2102645]133;A;cl=m;aid=2102645Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\k..lo/groundwork\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork\[?1h=[?1l>]133;C;Ptmux;]1337;SetUserVar=WEZTERM_PROG=dGVycmFmb3JtIHBsYW4=\kterraform\
Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  [32m+[0m create[0m

Terraform will perform the following actions:

[1m  # azurerm_network_security_group.ameciclo_nsg[0m will be created
[0m  [32m+[0m[0m resource "azurerm_network_security_group" "ameciclo_nsg" {
      [32m+[0m[0m id                  = (known after apply)
      [32m+[0m[0m location            = "eastus"
      [32m+[0m[0m name                = "ameciclo-security-group"
      [32m+[0m[0m resource_group_name = "ameciclo-prod-rg"
      [32m+[0m[0m security_rule       = [
          [32m+[0m[0m {
              [32m+[0m[0m access                                     = "Allow"
              [32m+[0m[0m destination_address_prefix                 = "*"
              [32m+[0m[0m destination_address_prefixes               = []
              [32m+[0m[0m destination_application_security_group_ids = []
              [32m+[0m[0m destination_port_range                     = "5432"
              [32m+[0m[0m destination_port_ranges                    = []
              [32m+[0m[0m direction                                  = "Inbound"
              [32m+[0m[0m name                                       = "Allow-Internet-Read"
              [32m+[0m[0m priority                                   = 200
              [32m+[0m[0m protocol                                   = "Tcp"
              [32m+[0m[0m source_address_prefix                      = "0.0.0.0/0"
              [32m+[0m[0m source_address_prefixes                    = []
              [32m+[0m[0m source_application_security_group_ids      = []
              [32m+[0m[0m source_port_range                          = "*"
              [32m+[0m[0m source_port_ranges                         = []
                [90m# (1 unchanged attribute hidden)[0m[0m
            },
        ]
      [32m+[0m[0m tags                = {
          [32m+[0m[0m "company"     = "Ameciclo"
          [32m+[0m[0m "environment" = "production"
          [32m+[0m[0m "project"     = "infrastructure"
        }
    }

[1m  # azurerm_resource_group.ameciclo[0m will be created
[0m  [32m+[0m[0m resource "azurerm_resource_group" "ameciclo" {
      [32m+[0m[0m id       = (known after apply)
      [32m+[0m[0m location = "eastus"
      [32m+[0m[0m name     = "ameciclo-prod-rg"
      [32m+[0m[0m tags     = {
          [32m+[0m[0m "company"     = "Ameciclo"
          [32m+[0m[0m "environment" = "production"
          [32m+[0m[0m "project"     = "infrastructure"
        }
    }

[1m  # azurerm_virtual_network.ameciclo_vnet[0m will be created
[0m  [32m+[0m[0m resource "azurerm_virtual_network" "ameciclo_vnet" {
      [32m+[0m[0m address_space       = [
          [32m+[0m[0m "10.0.0.0/16",
        ]
      [32m+[0m[0m dns_servers         = (known after apply)
      [32m+[0m[0m guid                = (known after apply)
      [32m+[0m[0m id                  = (known after apply)
      [32m+[0m[0m location            = "eastus"
      [32m+[0m[0m name                = "ameciclo-vnet"
      [32m+[0m[0m resource_group_name = "ameciclo-prod-rg"
      [32m+[0m[0m subnet              = [
          [32m+[0m[0m {
              [32m+[0m[0m address_prefix = "10.0.1.0/24"
              [32m+[0m[0m id             = (known after apply)
              [32m+[0m[0m name           = "default-subnet"
              [32m+[0m[0m security_group = (known after apply)
            },
        ]
      [32m+[0m[0m tags                = {
          [32m+[0m[0m "company"     = "Ameciclo"
          [32m+[0m[0m "environment" = "production"
          [32m+[0m[0m "project"     = "infrastructure"
        }
    }

[1mPlan:[0m 3 to add, 0 to change, 0 to destroy.
[0m[90m
─────────────────────────────────────────────────────────────────────────────[0m

Note: You didn't use the -out option to save this plan, so Terraform can't
guarantee to take exactly these actions if you run "terraform apply" now.
]133;D;0;aid=2102645]133;A;cl=m;aid=2102645Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\k..lo/groundwork\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork\[?1h=[?1l>]133;C;Ptmux;]1337;SetUserVar=WEZTERM_PROG=dGVycmFmb3JtIHBsYW4=\kterraform\
Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  [32m+[0m create[0m

Terraform will perform the following actions:

[1m  # azurerm_network_security_group.ameciclo_nsg[0m will be created
[0m  [32m+[0m[0m resource "azurerm_network_security_group" "ameciclo_nsg" {
      [32m+[0m[0m id                  = (known after apply)
      [32m+[0m[0m location            = "eastus"
      [32m+[0m[0m name                = "ameciclo-security-group"
      [32m+[0m[0m resource_group_name = "ameciclo-prod-rg"
      [32m+[0m[0m security_rule       = [
          [32m+[0m[0m {
              [32m+[0m[0m access                                     = "Allow"
              [32m+[0m[0m destination_address_prefix                 = "*"
              [32m+[0m[0m destination_address_prefixes               = []
              [32m+[0m[0m destination_application_security_group_ids = []
              [32m+[0m[0m destination_port_range                     = "5432"
              [32m+[0m[0m destination_port_ranges                    = []
              [32m+[0m[0m direction                                  = "Inbound"
              [32m+[0m[0m name                                       = "Allow-Internet-Read"
              [32m+[0m[0m priority                                   = 200
              [32m+[0m[0m protocol                                   = "Tcp"
              [32m+[0m[0m source_address_prefix                      = "0.0.0.0/0"
              [32m+[0m[0m source_address_prefixes                    = []
              [32m+[0m[0m source_application_security_group_ids      = []
              [32m+[0m[0m source_port_range                          = "*"
              [32m+[0m[0m source_port_ranges                         = []
                [90m# (1 unchanged attribute hidden)[0m[0m
            },
        ]
      [32m+[0m[0m tags                = {
          [32m+[0m[0m "company"     = "Ameciclo"
          [32m+[0m[0m "environment" = "production"
          [32m+[0m[0m "project"     = "infrastructure"
        }
    }

[1m  # azurerm_resource_group.ameciclo[0m will be created
[0m  [32m+[0m[0m resource "azurerm_resource_group" "ameciclo" {
      [32m+[0m[0m id       = (known after apply)
      [32m+[0m[0m location = "eastus"
      [32m+[0m[0m name     = "ameciclo-prod-rg"
      [32m+[0m[0m tags     = {
          [32m+[0m[0m "company"     = "Ameciclo"
          [32m+[0m[0m "environment" = "production"
          [32m+[0m[0m "project"     = "infrastructure"
        }
    }

[1m  # azurerm_virtual_network.ameciclo_vnet[0m will be created
[0m  [32m+[0m[0m resource "azurerm_virtual_network" "ameciclo_vnet" {
      [32m+[0m[0m address_space       = [
          [32m+[0m[0m "10.0.0.0/16",
        ]
      [32m+[0m[0m dns_servers         = (known after apply)
      [32m+[0m[0m guid                = (known after apply)
      [32m+[0m[0m id                  = (known after apply)
      [32m+[0m[0m location            = "eastus"
      [32m+[0m[0m name                = "ameciclo-vnet"
      [32m+[0m[0m resource_group_name = "ameciclo-prod-rg"
      [32m+[0m[0m subnet              = [
          [32m+[0m[0m {
              [32m+[0m[0m address_prefix = "10.0.1.0/24"
              [32m+[0m[0m id             = (known after apply)
              [32m+[0m[0m name           = "default-subnet"
              [32m+[0m[0m security_group = (known after apply)
            },
        ]
      [32m+[0m[0m tags                = {
          [32m+[0m[0m "company"     = "Ameciclo"
          [32m+[0m[0m "environment" = "production"
          [32m+[0m[0m "project"     = "infrastructure"
        }
    }

[1mPlan:[0m 3 to add, 0 to change, 0 to destroy.
[0m[90m
─────────────────────────────────────────────────────────────────────────────[0m

Note: You didn't use the -out option to save this plan, so Terraform can't
guarantee to take exactly these actions if you run "terraform apply" now.
]133;D;0;aid=2102645]133;A;cl=m;aid=2102645Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\k..lo/groundwork\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork\[?1h=[?1l>]133;C;Ptmux;]1337;SetUserVar=WEZTERM_PROG=dGVycmFmb3JtIHBsYW4=\kterraform\
Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  [32m+[0m create[0m

Terraform will perform the following actions:

[1m  # azurerm_network_security_group.ameciclo_nsg[0m will be created
[0m  [32m+[0m[0m resource "azurerm_network_security_group" "ameciclo_nsg" {
      [32m+[0m[0m id                  = (known after apply)
      [32m+[0m[0m location            = "eastus"
      [32m+[0m[0m name                = "ameciclo-security-group"
      [32m+[0m[0m resource_group_name = "ameciclo-prod-rg"
      [32m+[0m[0m security_rule       = [
          [32m+[0m[0m {
              [32m+[0m[0m access                                     = "Allow"
              [32m+[0m[0m destination_address_prefix                 = "*"
              [32m+[0m[0m destination_address_prefixes               = []
              [32m+[0m[0m destination_application_security_group_ids = []
              [32m+[0m[0m destination_port_range                     = "5432"
              [32m+[0m[0m destination_port_ranges                    = []
              [32m+[0m[0m direction                                  = "Inbound"
              [32m+[0m[0m name                                       = "Allow-Internet-Read"
              [32m+[0m[0m priority                                   = 200
              [32m+[0m[0m protocol                                   = "Tcp"
              [32m+[0m[0m source_address_prefix                      = "0.0.0.0/0"
              [32m+[0m[0m source_address_prefixes                    = []
              [32m+[0m[0m source_application_security_group_ids      = []
              [32m+[0m[0m source_port_range                          = "*"
              [32m+[0m[0m source_port_ranges                         = []
                [90m# (1 unchanged attribute hidden)[0m[0m
            },
        ]
      [32m+[0m[0m tags                = {
          [32m+[0m[0m "company"     = "Ameciclo"
          [32m+[0m[0m "environment" = "production"
          [32m+[0m[0m "project"     = "infrastructure"
        }
    }

[1m  # azurerm_resource_group.ameciclo[0m will be created
[0m  [32m+[0m[0m resource "azurerm_resource_group" "ameciclo" {
      [32m+[0m[0m id       = (known after apply)
      [32m+[0m[0m location = "eastus"
      [32m+[0m[0m name     = "ameciclo-prod-rg"
      [32m+[0m[0m tags     = {
          [32m+[0m[0m "company"     = "Ameciclo"
          [32m+[0m[0m "environment" = "production"
          [32m+[0m[0m "project"     = "infrastructure"
        }
    }

[1m  # azurerm_virtual_network.ameciclo_vnet[0m will be created
[0m  [32m+[0m[0m resource "azurerm_virtual_network" "ameciclo_vnet" {
      [32m+[0m[0m address_space       = [
          [32m+[0m[0m "10.0.0.0/16",
        ]
      [32m+[0m[0m dns_servers         = (known after apply)
      [32m+[0m[0m guid                = (known after apply)
      [32m+[0m[0m id                  = (known after apply)
      [32m+[0m[0m location            = "eastus"
      [32m+[0m[0m name                = "ameciclo-vnet"
      [32m+[0m[0m resource_group_name = "ameciclo-prod-rg"
      [32m+[0m[0m subnet              = [
          [32m+[0m[0m {
              [32m+[0m[0m address_prefix = "10.0.1.0/24"
              [32m+[0m[0m id             = (known after apply)
              [32m+[0m[0m name           = "default-subnet"
              [32m+[0m[0m security_group = (known after apply)
            },
        ]
      [32m+[0m[0m tags                = {
          [32m+[0m[0m "company"     = "Ameciclo"
          [32m+[0m[0m "environment" = "production"
          [32m+[0m[0m "project"     = "infrastructure"
        }
    }

[1mPlan:[0m 3 to add, 0 to change, 0 to destroy.
[0m[90m
─────────────────────────────────────────────────────────────────────────────[0m

Note: You didn't use the -out option to save this plan, so Terraform can't
guarantee to take exactly these actions if you run "terraform apply" now.
]133;D;0;aid=2102645]133;A;cl=m;aid=2102645Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\k..lo/groundwork\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork\[?1h=[?1l>]133;C;Ptmux;]1337;SetUserVar=WEZTERM_PROG=dGVycmFmb3JtIGluaXQ=\kterraform\[0m[1mInitializing the backend...[0m
[0m[1mInitializing provider plugins...[0m
- Reusing previous version of hashicorp/azurerm from the dependency lock file
- Using previously-installed hashicorp/azurerm v3.117.0

[0m[1m[32mTerraform has been successfully initialized![0m[32m[0m
[0m[32m
You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.[0m
]133;D;0;aid=2102645]133;A;cl=m;aid=2102645Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\k..lo/groundwork\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork\[?1h=[?1l>]133;C;Ptmux;]1337;SetUserVar=WEZTERM_PROG=dGVycmFmb3JtIHBsYW4=\kterraform\
Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  [32m+[0m create[0m

Terraform will perform the following actions:

[1m  # azurerm_network_security_group.ameciclo_nsg[0m will be created
[0m  [32m+[0m[0m resource "azurerm_network_security_group" "ameciclo_nsg" {
      [32m+[0m[0m id                  = (known after apply)
      [32m+[0m[0m location            = "eastus"
      [32m+[0m[0m name                = "ameciclo-security-group"
      [32m+[0m[0m resource_group_name = "ameciclo-prod-rg"
      [32m+[0m[0m security_rule       = [
          [32m+[0m[0m {
              [32m+[0m[0m access                                     = "Allow"
              [32m+[0m[0m destination_address_prefix                 = "*"
              [32m+[0m[0m destination_address_prefixes               = []
              [32m+[0m[0m destination_application_security_group_ids = []
              [32m+[0m[0m destination_port_range                     = "5432"
              [32m+[0m[0m destination_port_ranges                    = []
              [32m+[0m[0m direction                                  = "Inbound"
              [32m+[0m[0m name                                       = "Allow-Internet-Read"
              [32m+[0m[0m priority                                   = 200
              [32m+[0m[0m protocol                                   = "Tcp"
              [32m+[0m[0m source_address_prefix                      = "0.0.0.0/0"
              [32m+[0m[0m source_address_prefixes                    = []
              [32m+[0m[0m source_application_security_group_ids      = []
              [32m+[0m[0m source_port_range                          = "*"
              [32m+[0m[0m source_port_ranges                         = []
                [90m# (1 unchanged attribute hidden)[0m[0m
            },
        ]
      [32m+[0m[0m tags                = {
          [32m+[0m[0m "company"     = "Ameciclo"
          [32m+[0m[0m "environment" = "production"
          [32m+[0m[0m "project"     = "infrastructure"
        }
    }

[1m  # azurerm_resource_group.ameciclo[0m will be created
[0m  [32m+[0m[0m resource "azurerm_resource_group" "ameciclo" {
      [32m+[0m[0m id       = (known after apply)
      [32m+[0m[0m location = "eastus"
      [32m+[0m[0m name     = "ameciclo-prod-rg"
      [32m+[0m[0m tags     = {
          [32m+[0m[0m "company"     = "Ameciclo"
          [32m+[0m[0m "environment" = "production"
          [32m+[0m[0m "project"     = "infrastructure"
        }
    }

[1m  # azurerm_virtual_network.ameciclo_vnet[0m will be created
[0m  [32m+[0m[0m resource "azurerm_virtual_network" "ameciclo_vnet" {
      [32m+[0m[0m address_space       = [
          [32m+[0m[0m "10.0.0.0/16",
        ]
      [32m+[0m[0m dns_servers         = (known after apply)
      [32m+[0m[0m guid                = (known after apply)
      [32m+[0m[0m id                  = (known after apply)
      [32m+[0m[0m location            = "eastus"
      [32m+[0m[0m name                = "ameciclo-vnet"
      [32m+[0m[0m resource_group_name = "ameciclo-prod-rg"
      [32m+[0m[0m subnet              = [
          [32m+[0m[0m {
              [32m+[0m[0m address_prefix = "10.0.1.0/24"
              [32m+[0m[0m id             = (known after apply)
              [32m+[0m[0m name           = "default-subnet"
              [32m+[0m[0m security_group = (known after apply)
            },
        ]
      [32m+[0m[0m tags                = {
          [32m+[0m[0m "company"     = "Ameciclo"
          [32m+[0m[0m "environment" = "production"
          [32m+[0m[0m "project"     = "infrastructure"
        }
    }

[1mPlan:[0m 3 to add, 0 to change, 0 to destroy.
[0m[90m
─────────────────────────────────────────────────────────────────────────────[0m

Note: You didn't use the -out option to save this plan, so Terraform can't
guarantee to take exactly these actions if you run "terraform apply" now.
]133;D;0;aid=2102645]133;A;cl=m;aid=2102645Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\k..lo/groundwork\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork\[?1h=[?1l>]133;C;Ptmux;]1337;SetUserVar=WEZTERM_PROG=dGVycmFmb3JtIHBsYW4gLW91dD10ZnBsYW4K\kterraform\
Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  [32m+[0m create[0m

Terraform will perform the following actions:

[1m  # azurerm_network_security_group.ameciclo_nsg[0m will be created
[0m  [32m+[0m[0m resource "azurerm_network_security_group" "ameciclo_nsg" {
      [32m+[0m[0m id                  = (known after apply)
      [32m+[0m[0m location            = "eastus"
      [32m+[0m[0m name                = "ameciclo-security-group"
      [32m+[0m[0m resource_group_name = "ameciclo-prod-rg"
      [32m+[0m[0m security_rule       = [
          [32m+[0m[0m {
              [32m+[0m[0m access                                     = "Allow"
              [32m+[0m[0m destination_address_prefix                 = "*"
              [32m+[0m[0m destination_address_prefixes               = []
              [32m+[0m[0m destination_application_security_group_ids = []
              [32m+[0m[0m destination_port_range                     = "5432"
              [32m+[0m[0m destination_port_ranges                    = []
              [32m+[0m[0m direction                                  = "Inbound"
              [32m+[0m[0m name                                       = "Allow-Internet-Read"
              [32m+[0m[0m priority                                   = 200
              [32m+[0m[0m protocol                                   = "Tcp"
              [32m+[0m[0m source_address_prefix                      = "0.0.0.0/0"
              [32m+[0m[0m source_address_prefixes                    = []
              [32m+[0m[0m source_application_security_group_ids      = []
              [32m+[0m[0m source_port_range                          = "*"
              [32m+[0m[0m source_port_ranges                         = []
                [90m# (1 unchanged attribute hidden)[0m[0m
            },
        ]
      [32m+[0m[0m tags                = {
          [32m+[0m[0m "company"     = "Ameciclo"
          [32m+[0m[0m "environment" = "production"
          [32m+[0m[0m "project"     = "infrastructure"
        }
    }

[1m  # azurerm_resource_group.ameciclo[0m will be created
[0m  [32m+[0m[0m resource "azurerm_resource_group" "ameciclo" {
      [32m+[0m[0m id       = (known after apply)
      [32m+[0m[0m location = "eastus"
      [32m+[0m[0m name     = "ameciclo-prod-rg"
      [32m+[0m[0m tags     = {
          [32m+[0m[0m "company"     = "Ameciclo"
          [32m+[0m[0m "environment" = "production"
          [32m+[0m[0m "project"     = "infrastructure"
        }
    }

[1m  # azurerm_virtual_network.ameciclo_vnet[0m will be created
[0m  [32m+[0m[0m resource "azurerm_virtual_network" "ameciclo_vnet" {
      [32m+[0m[0m address_space       = [
          [32m+[0m[0m "10.0.0.0/16",
        ]
      [32m+[0m[0m dns_servers         = (known after apply)
      [32m+[0m[0m guid                = (known after apply)
      [32m+[0m[0m id                  = (known after apply)
      [32m+[0m[0m location            = "eastus"
      [32m+[0m[0m name                = "ameciclo-vnet"
      [32m+[0m[0m resource_group_name = "ameciclo-prod-rg"
      [32m+[0m[0m subnet              = [
          [32m+[0m[0m {
              [32m+[0m[0m address_prefix = "10.0.1.0/24"
              [32m+[0m[0m id             = (known after apply)
              [32m+[0m[0m name           = "default-subnet"
              [32m+[0m[0m security_group = (known after apply)
            },
        ]
      [32m+[0m[0m tags                = {
          [32m+[0m[0m "company"     = "Ameciclo"
          [32m+[0m[0m "environment" = "production"
          [32m+[0m[0m "project"     = "infrastructure"
        }
    }

[1mPlan:[0m 3 to add, 0 to change, 0 to destroy.
[0m[90m
─────────────────────────────────────────────────────────────────────────────[0m

Saved the plan to: tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "tfplan"
]133;D;0;aid=2102645]133;A;cl=m;aid=2102645Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\k..lo/groundwork\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork\[?1h=[?1l>]133;C;Ptmux;]1337;SetUserVar=WEZTERM_PROG=dGVycmFmb3JtIGFwcGx5\kterraform\
Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  [32m+[0m create[0m

Terraform will perform the following actions:

[1m  # azurerm_network_security_group.ameciclo_nsg[0m will be created
[0m  [32m+[0m[0m resource "azurerm_network_security_group" "ameciclo_nsg" {
      [32m+[0m[0m id                  = (known after apply)
      [32m+[0m[0m location            = "eastus"
      [32m+[0m[0m name                = "ameciclo-security-group"
      [32m+[0m[0m resource_group_name = "ameciclo-prod-rg"
      [32m+[0m[0m security_rule       = [
          [32m+[0m[0m {
              [32m+[0m[0m access                                     = "Allow"
              [32m+[0m[0m destination_address_prefix                 = "*"
              [32m+[0m[0m destination_address_prefixes               = []
              [32m+[0m[0m destination_application_security_group_ids = []
              [32m+[0m[0m destination_port_range                     = "5432"
              [32m+[0m[0m destination_port_ranges                    = []
              [32m+[0m[0m direction                                  = "Inbound"
              [32m+[0m[0m name                                       = "Allow-Internet-Read"
              [32m+[0m[0m priority                                   = 200
              [32m+[0m[0m protocol                                   = "Tcp"
              [32m+[0m[0m source_address_prefix                      = "0.0.0.0/0"
              [32m+[0m[0m source_address_prefixes                    = []
              [32m+[0m[0m source_application_security_group_ids      = []
              [32m+[0m[0m source_port_range                          = "*"
              [32m+[0m[0m source_port_ranges                         = []
                [90m# (1 unchanged attribute hidden)[0m[0m
            },
        ]
      [32m+[0m[0m tags                = {
          [32m+[0m[0m "company"     = "Ameciclo"
          [32m+[0m[0m "environment" = "production"
          [32m+[0m[0m "project"     = "infrastructure"
        }
    }

[1m  # azurerm_resource_group.ameciclo[0m will be created
[0m  [32m+[0m[0m resource "azurerm_resource_group" "ameciclo" {
      [32m+[0m[0m id       = (known after apply)
      [32m+[0m[0m location = "eastus"
      [32m+[0m[0m name     = "ameciclo-prod-rg"
      [32m+[0m[0m tags     = {
          [32m+[0m[0m "company"     = "Ameciclo"
          [32m+[0m[0m "environment" = "production"
          [32m+[0m[0m "project"     = "infrastructure"
        }
    }

[1m  # azurerm_virtual_network.ameciclo_vnet[0m will be created
[0m  [32m+[0m[0m resource "azurerm_virtual_network" "ameciclo_vnet" {
      [32m+[0m[0m address_space       = [
          [32m+[0m[0m "10.0.0.0/16",
        ]
      [32m+[0m[0m dns_servers         = (known after apply)
      [32m+[0m[0m guid                = (known after apply)
      [32m+[0m[0m id                  = (known after apply)
      [32m+[0m[0m location            = "eastus"
      [32m+[0m[0m name                = "ameciclo-vnet"
      [32m+[0m[0m resource_group_name = "ameciclo-prod-rg"
      [32m+[0m[0m subnet              = [
          [32m+[0m[0m {
              [32m+[0m[0m address_prefix = "10.0.1.0/24"
              [32m+[0m[0m id             = (known after apply)
              [32m+[0m[0m name           = "default-subnet"
              [32m+[0m[0m security_group = (known after apply)
            },
        ]
      [32m+[0m[0m tags                = {
          [32m+[0m[0m "company"     = "Ameciclo"
          [32m+[0m[0m "environment" = "production"
          [32m+[0m[0m "project"     = "infrastructure"
        }
    }

[1mPlan:[0m 3 to add, 0 to change, 0 to destroy.
[0m[0m[1m
Do you want to perform these actions?[0m
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  [1mEnter a value:[0m [0m

Interrupt received.
Please wait for Terraform to exit or data loss may occur.
Gracefully shutting down...

]133;D;1;aid=2102645]133;A;cl=m;aid=2102645Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\k..lo/groundwork\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork\[?1h=]133;D;130;aid=2102645]133;A;cl=m;aid=2102645Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\k..lo/groundwork\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork\[?1h=[?1l>]133;C;Ptmux;]1337;SetUserVar=WEZTERM_PROG=YXogZ3JvdXAgbGlzdCAtLW91dHB1dCB0YWJsZQo=\kaz\
]133;D;0;aid=2102645]133;A;cl=m;aid=2102645Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\k..lo/groundwork\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork\[?1h=[?1l>]133;C;Ptmux;]1337;SetUserVar=WEZTERM_PROG=dGVycmFmb3JtIGluaXQ=\kterraform\[0m[1mInitializing the backend...[0m
[0m[1mInitializing provider plugins...[0m
- Finding hashicorp/azurerm versions matching ">= 3.0.0"...
- Installing hashicorp/azurerm v4.11.0...
- Installed hashicorp/azurerm v4.11.0 (signed by HashiCorp)
Terraform has created a lock file [1m.terraform.lock.hcl[0m to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.[0m

[0m[1m[32mTerraform has been successfully initialized![0m[32m[0m
[0m[32m
You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.[0m
]133;D;0;aid=2102645]133;A;cl=m;aid=2102645Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\k..lo/groundwork\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork\[?1h=[?1l>]133;C;Ptmux;]1337;SetUserVar=WEZTERM_PROG=dGVycmFmb3JtIHBsYW4=\kterraform\]133;D;1;aid=2102645]133;A;cl=m;aid=2102645Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\k..lo/groundwork\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork\[?1h=[?1l>]133;C;Ptmux;]1337;SetUserVar=WEZTERM_PROG=dGVycmFmb3JtIHZhbGlkYXRl\kterraform\[32m[1mSuccess![0m The configuration is valid.
[0m
]133;D;0;aid=2102645]133;A;cl=m;aid=2102645Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\k..lo/groundwork\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork\[?1h=[?1l>]133;C;Ptmux;]1337;SetUserVar=WEZTERM_PROG=dGVycmFmb3JtIHBsYW4=\kterraform\
[0m[1m[31mPlanning failed.[0m[1m Terraform encountered an error while generating this plan.[0m

[0m]133;D;1;aid=2102645]133;A;cl=m;aid=2102645Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\k..lo/groundwork\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork\[?1h=]133;D;130;aid=2102645]133;A;cl=m;aid=2102645Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\k..lo/groundwork\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork\[?1h=]133;D;130;aid=1775529]133;A;cl=m;aid=1775529Ptmux;]1337;SetUserVar=WEZTERM_PROG=\Ptmux;]1337;SetUserVar=WEZTERM_USER=cGxwYnM=\Ptmux;]1337;SetUserVar=WEZTERM_IN_TMUX=MQ==\Ptmux;]1337;SetUserVar=WEZTERM_HOST=YXBvbG8=\Ptmux;]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\\]7;file://apolo/home/plpbs/Projetos/Ameciclo/groundwork/\[0m[1mInitializing the backend...[0m
[0m[1mInitializing provider plugins...[0m
- Reusing previous version of hashicorp/azurerm from the dependency lock file
- Reusing previous version of azure/azapi from the dependency lock file
- Using previously-installed hashicorp/azurerm v4.11.0
- Using previously-installed azure/azapi v2.0.1

[0m[1m[32mTerraform has been successfully initialized![0m[32m[0m
[0m[32m
You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.[0m

## Structure
- **main.tf**: The root configuration file.
- **variables.tf**: Input variables.
- **outputs.tf**: Outputs for the Terraform configuration.
- **modules/**: Contains reusable modules.
- **environments/**: Per-environment configurations.

## Notes
- Ensure you have an S3 bucket and DynamoDB table set up for the backend.
