---
applyTo: '**'
---
Provide project context and coding guidelines that AI should follow when generating code, answering questions, or reviewing changes.


Só edite arquivos quando eu pedir. O mesmo para apagar arquivos.
# Instruções para Módulo Terraform 
Sempre utilize o provider `bpg/proxmox` na versão `0.83.2` ou superior.
Usando o mcp do terraform, sempre busque o provider bpg, namespace proxmox e versão latest.
Sempre faça de acordo com a documentação oficial do provider: https://registry.terraform.io/providers/bpg/proxmox/latest/docs


# Boas Práticas
- Sempre utilize variáveis para valores que podem mudar, como nomes de recursos, tamanhos,

- Siga os padrões de arquitetura e design recomendados pela HashiCorp para organizar o código Terraform.

- Siga os padrões de estrutura de pastas recomendados pela HashiCorp para organizar o código Terraform.

- Caso tenha necessidade, separe em módulos reutilizáveis para facilitar a manutenção e a reutilização do código.

- Siga a ideia de liguagem declarativa, focando no "o que" deve ser feito, e não no "como" deve ser feito.

- siga o modelo KISS (Keep It Simple, Stupid) para manter o código simples e fácil de entender.

