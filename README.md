# Documentação Técnica do Laboratório de Redes com MikroTik

---

## 1. Introdução

Este documento descreve a arquitetura, configuração e funcionalidades de um laboratório de redes simulado utilizando equipamentos MikroTik (via WinBox e terminal), roteadores, switches, PCs e conexões simuladas com provedores de internet (ISP). O objetivo é demonstrar a implementação de protocolos avançados como **iBGP**, **OSPF**, **VRRP**, **Load Balancing** e **VLANs**, em um ambiente de rede com redundância e alta disponibilidade.

O laboratório foi construído em um ambiente virtualizado (GNS3) com o uso de adaptadores VMnet8 para simular conexões com nuvens externas (Cloud/ISP).

<img width="500" height="500" alt="laboratorio MK" src="https://github.com/user-attachments/assets/3dcf0a6b-dc0d-4dbb-93e2-ae2199fc8f2b" />

---

## 2. Arquitetura da Rede

A topologia apresenta uma estrutura hierárquica com:

- Dois **provedores de internet (ISP1 e ISP2)** conectados ao núcleo.
- Um **roteador central (R1)** que atua como ponto de entrada para os ISPs e distribui tráfego interno.
- Dois **roteadores internos (R2 e R3)** conectados a R1 e a um switch central.
- Um **switch (SW1)** que gerencia VLANs e conecta os PCs.
- 2 **PCs (PC1 e PC2)** com IPs estáticos ou dinâmicos.
- Dois **equipamentos MikroTik** utilizados como clientes ou testadores de rede.

---

## 3. Componentes da Rede

| Dispositivo | Tipo | Função |
|------------|------|--------|
| **ISP1** | Cloud / Router | Provedor de Internet 1; DHCP e iBGP AS 5555 |
| **ISP2** | Cloud / Router | Provedor de Internet 2; DHCP e iBGP AS 2250 |
| **R1** | Roteador MikroTik | Roteador principal: iBGP, Load Balance, OSPF |
| **R2** | Roteador MikroTik | Roteador interno: VRRP, OSPF, VLAN10/VLAN20 |
| **R3** | Roteador MikroTik | Roteador interno: VRRP, OSPF, VLAN10/VLAN20 |
| **SW1** | Switch MikroTik | Switch central: VLANs, L2, Bridge |
| **PC1** | PC Virtual | Cliente na VLAN10 (192.168.10.10) |
| **PC2** | PC Virtual | Cliente na VLAN20 (192.168.20.20) |
| **MikroTikWinBox-1, -2, -3** | Clientes MikroTik | Acesso remoto via WinBox |

---

## 4. Topologia Detalhada

### 4.1. Conexões e Interfaces

#### **ISP1**
- `ether1`: Conectado à **Cloud** (VMware Network Adapter VMnet8)
- `ether2`: Conectado a **R1** → `171.99.10.1` /24
- `ether24`: Conectado a **MikroTikWinBox-3**

#### **ISP2**
- `ether1`: Conectado à **Cloud1** (VMware Network Adapter VMnet8)
- `ether2`: Conectado a **R1** → `172.166.10.1` /24
- `ether24`: Conectado a **MikroTikWinBox-2**

#### **R1 (Roteador Central)**
- `ether1`: Conectado a **ISP1** → `171.99.10.175` /24
- `ether2`: Conectado a **ISP2** → `172.166.10.100` /24
- `ether4`: Conectado a **R2** → `10.10.1.1` /24
- `ether5`: Conectado a **R3** → `10.10.2.1` /24

#### **R2**
- `ether1`: Conectado a **R1** → `10.10.1.2` /24
- `ether2`: Conectado a **R3** → `10.10.3.1` /24
- `ether3`: Conectado a **SW1** → VLAN10 e VLAN20

#### **R3**
- `ether1`: Conectado a **R1** → `10.10.2.2` /24
- `ether2`: Conectado a **R2** → `10.10.3.2` /24
- `ether3`: Conectado a **SW1** → VLAN10 e VLAN20

#### **SW1**
- `ether1`: Conectado a **R2** (VLAN10/VLAN20)
- `ether2`: Conectado a **R3** (VLAN10/VLAN20)
- `ether3`: Conectado a **PC1** (VLAN10)
- `ether5`: Conectado a **PC2** (VLAN20)
- `ether24`: Conectado a **MikroTikWinBox-1**

#### **PCs**
- **PC1**: `192.168.10.10` /24 (VLAN10)
- **PC2**: `192.168.20.20` /24 (VLAN20)
- **VPCS**: IP estático (configurável)

---

## 5. Protocolos e Funcionalidades Implementados

### 5.1. iBGP (Interior Border Gateway Protocol)
- **AS 5555**: ISP1 e R1
- **AS 2250**: ISP2 e R1
- R1 estabelece sessões iBGP com ambos os ISPs para troca de rotas.
- Permite balanceamento de carga entre dois caminhos para a internet.

### 5.2. Load Balancing
- R1 realiza **balanceamento de carga** entre ISP1 e ISP2.
- Rotas para a internet são distribuídas pelos dois links.
- Utiliza-se **iBGP + múltiplas sessões de BGP** para equal-cost multipath (ECMP).

### 5.3. OSPF (Open Shortest Path First)
- **Área 0**: R1, R2, R3 formam uma área OSPF.
- Anunciam rotas internas entre si.
- R1 anuncia rotas para as redes locais (10.10.x.x) e redes dos ISPs.
- R2 e R3 aprendem rotas via OSPF e propagam para suas VLANs.

### 5.4. VRRP (Virtual Router Redundancy Protocol)
- R2 e R3 atuam como **routers virtuais redundantes**.
- Uma das interfaces (por exemplo, `ether3`) em R2 e R3 pertence a um grupo VRRP.
- Em caso de falha de um roteador, o outro assume a função de gateway padrão.
- Garante continuidade de serviço para os PCs.

### 5.5. VLANs (Virtual LANs)
- **VLAN10**: Rede 192.168.10.0/24 → PC1
- **VLAN20**: Rede 192.168.20.0/24 → PC2
- SW1 atua como **bridge** entre VLANs.
- R2 e R3 são configurados como **gateways por VLAN**.

### 5.6. DHCP
- **ISP1 e ISP2**: Atuam como servidores DHCP para fornecer IPs dinâmicos aos dispositivos conectados.
- Os dispositivos MikroTik podem receber IPs via DHCP quando conectados diretamente.

### 5.7. Bridge (SW1)
- SW1 funciona como um **bridge L2**, conectando os roteadores R2 e R3 com os PCs.
- Realiza encapsulamento de VLANs nas portas físicas.
- Suporta comunicação entre VLANs via roteamento nos roteadores.

---

## 6. Configurações de IP

### Rede Interna (10.10.0.0/24)

| Dispositivo | Interface | IP | Máscara |
|-------------|-----------|-----|---------|
| R1 | ether4 | 10.10.1.1 | /24 |
| R2 | ether1 | 10.10.1.2 | /24 |
| R1 | ether5 | 10.10.2.1 | /24 |
| R3 | ether1 | 10.10.2.2 | /24 |
| R2 | ether2 | 10.10.3.1 | /24 |
| R3 | ether2 | 10.10.3.2 | /24 |

### Redes de Acesso (VLANs)

| VLAN | Rede | Gateway | PC |
|------|------|---------|-----|
| VLAN10 | 192.168.10.0/24 | 192.168.10.1 (R2/R3) | PC1: 192.168.10.10 |
| VLAN20 | 192.168.20.0/24 | 192.168.20.1 (R2/R3) | PC2: 192.168.20.20 |

### Conexões com ISPs

| Link | IP | Subrede |
|------|-----|--------|
| ISP1 → R1 | 171.99.10.1 → 171.99.10.175 | /24 |
| ISP2 → R1 | 172.166.10.1 → 172.166.10.100 | /24 |

---

## 7. Configuração de Roteamento

### 7.1. R1 – Configuração Principal
```bash
# iBGP com ISP1 (AS 5555)
/ip route add dst-address=0.0.0.0/0 gateway=171.99.10.1 distance=10
/ip route add dst-address=0.0.0.0/0 gateway=172.166.10.1 distance=10

# OSPF
/routing ospf instance set default comment="Default Instance"
/routing ospf network add network=10.10.0.0/24 area=backbone

# Load Balance
/ip route add dst-address=0.0.0.0/0 gateway=171.99.10.1 distance=1
/ip route add dst-address=0.0.0.0/0 gateway=172.166.10.1 distance=1
```
### 7.2. R2 e R3 – Configuração de VRRP e OSPF 
```bash
# VRRP no R2 (Master)
/ip vrrp add interface=ether3 virtual-router-id=1 priority=100
/ip vrrp add interface=ether3 virtual-router-id=1 priority=100

# OSPF
/routing ospf network add network=10.10.0.0/24 area=backbone
/routing ospf network add network=192.168.10.0/24 area=backbone
/routing ospf network add network=192.168.20.0/24 area=backbone
 ````
 
### 7.3. SW1 – VLANs e Bridge 
````bash
# Criar VLANs
/interface vlan add name=vlan10 interface=ether3 vlan-id=10
/interface vlan add name=vlan20 interface=ether3 vlan-id=20

# Bridge
/interface bridge add name=bridge1
/interface bridge port add interface=ether1 bridge=bridge1
/interface bridge port add interface=ether2 bridge=bridge1
/interface bridge port add interface=ether3 bridge=bridge1
/interface bridge port add interface=ether5 bridge=bridge1
 ````

---
 
## 8. Testes e Verificações 
### 8.1. Testes de Conectividade
    Ping dos PCs para os Gateways (R2 e R3)
    Ping para Internet: PC1 → 8.8.8.8 (via R1 → ISP1/ISP2)
    Failover VRRP: Desativar R2 → PC1 deve continuar com acesso via R3
    Balanceamento de Carga: Monitorar tráfego em ambas as interfaces ISP1 e ISP2
     

### 8.2. Comandos de Diagnóstico 
````bash
/ip route print
/ip arp print
/ip neighbor print
/routing ospf peer print
/ip vrrp print
````

 --- 
 
## 9. Considerações Finais 

Este laboratório demonstra uma arquitetura robusta com: 

    Alta disponibilidade via VRRP e redundância de ISPs
    Escalabilidade com OSPF e iBGP
    Segregação de tráfego com VLANs
    Balanceamento de carga para otimização de recursos
    Gestão centralizada via MikroTik WinBox
     

É ideal para treinamento em: 

    Roteamento avançado
    Redundância de redes
    Gerenciamento de VLANs
    Configuração de serviços de rede em ambientes corporativos
     

---
 
## 10. Anexos 

### Diagrama de Topologia 

<img width="1080" height="811" alt="laboratorio MK" src="https://github.com/user-attachments/assets/3dcf0a6b-dc0d-4dbb-93e2-ae2199fc8f2b" />

---

### iBGP estabilished
<img width="735" height="521" alt="image" src="https://github.com/user-attachments/assets/e2463931-9ef6-47f0-8fb0-f599e1bdaa39" />

---

### Rotas R1 (load balance, ospf e iBGP)

<img width="735" height="590" alt="image" src="https://github.com/user-attachments/assets/21fe291b-b7d0-4ba1-a854-2b4757d35a1b" />


---

### Troubleshooting Load balancing

<img width="895" height="670" alt="Captura de tela 2025-08-26 140905" src="https://github.com/user-attachments/assets/5e493e82-f7e8-4143-ac4e-8ba547d59eaf" />
<img width="895" height="670" alt="Captura de tela 2025-08-26 140855" src="https://github.com/user-attachments/assets/4ac49535-72cf-4456-a890-0e8f3bf04feb" />

---

### Configuração R2 (VLANs, endereços IPs e VRRP)

<img width="861" height="412" alt="image" src="https://github.com/user-attachments/assets/b6e7d6d7-356c-43c1-a3ea-c37ac589e21d" />

---

### Configuração R3 (VLANs, endereços IPs e VRRP)

<img width="832" height="389" alt="image" src="https://github.com/user-attachments/assets/659a3d3a-48ff-4061-9e3b-4b20aaafec3a" />



## Lista de Equipamentos 

    CHR 7.16
    GNS3
    Terminal Putty
    WinBox para configuração remota
    VirtualBox (GNS3 SERVER) 

---
 
````
Autora: Caroline Bento
Data: Agosto de 2025
Versão: 1.0
Finalidade: Treinamento técnico em redes corporativas com MikroTik 

