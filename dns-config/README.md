````markdown
# Configuração de Servidor DNS BIND9 para Rede Local

Este documento descreve o processo de instalação e configuração de um servidor DNS autoritativo e recursivo usando BIND9 em um sistema baseado em Debian/Ubuntu. O objetivo é fornecer resolução de nomes para hosts internos (ex: `proxmox.home.lan`) e cache para consultas externas.

## Tabela de Conteúdos

1.  [Pré-requisitos](#1-pré-requisitos)
2.  [Instalação](#2-instalação)
3.  [Configuração Global e Segurança (ACL e Forwarders)](#3-configuração-global-e-segurança-acl-e-forwarders)
4.  [Configuração da Zona Direta (Forward Zone)](#4-configuração-da-zona-direta-forward-zone)
5.  [Configuração da Zona Reversa (Reverse Zone)](#5-configuração-da-zona-reversa-reverse-zone)
6.  [Validação da Configuração](#6-validação-da-configuração)
7.  [Configuração de Atualizações Dinâmicas (DDNS via nsupdate)](#7-configuração-de-atualizações-dinâmicas-ddns-via-nsupdate)
8.  [Configuração do Cliente (DHCP)](#8-configuração-do-cliente-dhcp)

---

### 1. Pré-requisitos

* Um servidor ou container LXC com sistema operacional Debian ou Ubuntu.
* Um endereço IP estático configurado no servidor BIND (ex: `192.168.1.10`).
* Acesso root ou privilégios `sudo`.

### 2. Instalação

Instale os pacotes necessários do BIND e utilitários de DNS:

```bash
sudo apt update
sudo apt install bind9 bind9utils dnsutils -y
````

### 3\. Configuração Global e Segurança (ACL e Forwarders)

Edite o arquivo `/etc/bind/named.conf.options` para definir quem pode consultar seu servidor e para onde encaminhar consultas externas.

**Boas práticas:**

  * **ACL (Access Control List):** Restrinja as consultas recursivas apenas à sua rede local para evitar que seu servidor seja usado em ataques de amplificação de DNS.
  * **Forwarders:** Use servidores DNS públicos confiáveis para resolver domínios da internet.

**Exemplo de `/etc/bind/named.conf.options`:**

```bind
// Define uma lista de acesso para a rede local confiável
acl "trusted_network" {
    127.0.0.1;        // localhost
    192.168.1.0/24;   // Sua rede local
};

options {
    directory "/var/cache/bind";

    // Permitir consultas recursivas apenas de clientes na rede confiável
    allow-query { trusted_network; };
    recursion yes;

    // Encaminhar consultas externas para servidores públicos
    forwarders {
        1.1.1.1;  // Cloudflare DNS
        8.8.8.8;  // Google DNS
    };
};
```

### 4\. Configuração da Zona Direta (Forward Zone)

A zona direta traduz nomes de host para endereços IP (ex: `proxmox.home.lan` -\> `192.168.1.11`).

**a. Declare a zona em `/etc/bind/named.conf.local`:**

```bind
// Zona Direta para home.lan
zone "home.lan" IN {
    type master;
    file "/etc/bind/zones/db.home.lan"; // Caminho para o arquivo de zona
    allow-update { none; }; // Mudar isso depois para DDNS (ver Passo 7)
};
```

**b. Crie o arquivo de zona `/etc/bind/zones/db.home.lan`:**

*Crie o diretório `/etc/bind/zones` se ele não existir.*

```bind
; Arquivo de Zona para home.lan
$TTL    604800 ; Tempo de vida padrão (7 dias)

@       IN      SOA     dns-server.home.lan. admin.home.lan. (
                        2025090901      ; Serial (Formato YYYYMMDDNN - Incrementar a cada mudança)
                        604800          ; Refresh (1 semana)
                        86400           ; Retry (1 dia)
                        2419200         ; Expire (4 semanas)
                        604800 )        ; Negative Cache TTL

; Registros do Servidor de Nomes (NS)
@       IN      NS      dns-server.home.lan.

; Registros de Endereço (A)
dns-server      IN      A       192.168.1.10   ; IP do servidor BIND
proxmox         IN      A       192.168.1.11   ; IP do host Proxmox
roteador        IN      A       192.168.1.1
```

### 5\. Configuração da Zona Reversa (Reverse Zone)

A zona reversa traduz endereços IP de volta para nomes de host (ex: `192.168.1.11` -\> `proxmox.home.lan`).

**a. Calcule o nome da zona reversa:**
Para a rede `192.168.1.0/24`, inverta os octetos da rede: `1.168.192` e adicione `.in-addr.arpa`.
Resultado: `1.168.192.in-addr.arpa`

**b. Declare a zona em `/etc/bind/named.conf.local`:**

```bind
// Zona Reversa para 192.168.1.x
zone "1.168.192.in-addr.arpa" IN {
    type master;
    file "/etc/bind/zones/db.192.168.1"; // Caminho para o arquivo de zona reversa
    allow-update { none; }; // Mudar isso depois para DDNS (ver Passo 7)
};
```

**c. Crie o arquivo de zona `/etc/bind/zones/db.192.168.1`:**

```bind
; Arquivo de Zona Reversa para 192.168.1.x
$TTL    604800
@       IN      SOA     dns-server.home.lan. admin.home.lan. (
                        2025090901      ; Serial (Deve ser o mesmo da zona direta para consistência)
                        ... )

@       IN      NS      dns-server.home.lan.

; Registros PTR (IP -> Nome) - Apenas o último octeto do IP
10      IN      PTR     dns-server.home.lan.
11      IN      PTR     proxmox.home.lan.
1       IN      PTR     roteador.home.lan.
```

### 6\. Validação da Configuração

Antes de reiniciar o BIND, verifique a sintaxe dos seus arquivos:

```bash
# Verificar a configuração principal
sudo named-checkconf

# Verificar a zona direta
sudo named-checkzone home.lan /etc/bind/zones/db.home.lan

# Verificar a zona reversa
sudo named-checkzone 1.168.192.in-addr.arpa /etc/bind/zones/db.192.168.1
```

Se todos os comandos retornarem "OK", reinicie o BIND:

```bash
sudo systemctl restart bind9
```

### 7\. Configuração de Atualizações Dinâmicas (DDNS via nsupdate)

Para automatizar a adição de registros sem editar arquivos manualmente, ative as atualizações dinâmicas seguras.

**a. Gerar a Chave TSIG:**

```bash
# Gera uma chave e salva no arquivo de configuração
sudo tsig-keygen -a hmac-sha256 ddns-key > /etc/bind/ddns-key.conf
```

**b. Configurar o BIND para usar a chave:**

Edite `/etc/bind/named.conf.local` novamente:

```bash
# Incluir a chave gerada
include "/etc/bind/ddns-key.conf";

# Modificar as zonas para permitir updates com a chave
zone "home.lan" IN {
    type master;
    file "/etc/bind/zones/db.home.lan";
    allow-update { key "ddns-key"; }; // <--- ADICIONAR ISSO
};

zone "1.168.192.in-addr.arpa" IN {
    type master;
    file "/etc/bind/zones/db.192.168.1";
    allow-update { key "ddns-key"; }; // <--- ADICIONAR ISSO
};
```

**c. Reiniciar o BIND:** `sudo systemctl restart bind9`

**d. Script de Exemplo para Adicionar Registro via `nsupdate`:**

```bash
#!/bin/bash
# add_record.sh <hostname> <ip_address>

HOSTNAME=$1
IP_ADDRESS=$2
ZONE="home.lan"
KEYFILE="/etc/bind/ddns-key.conf"

nsupdate -v -k $KEYFILE << EOF
server 127.0.0.1
zone $ZONE
update add ${HOSTNAME}.${ZONE}. 300 IN A $IP_ADDRESS
send
quit
EOF
```

### 8\. Configuração do Cliente (DHCP)

Para que todos os dispositivos da rede usem seu novo servidor DNS:

1.  Acesse a interface de administração do seu roteador principal.
2.  Vá para as configurações do **Servidor DHCP**.
3.  Defina os servidores DNS distribuídos:
      * **DNS Primário:** `192.168.1.x` (IP do seu servidor BIND)
      * **DNS Secundário:** `1.1.1.1` (Um DNS público para redundância)

<!-- end list -->

```
```