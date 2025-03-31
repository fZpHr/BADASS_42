## P3 - BGP / EVPN

Le protocole **BGP (Border Gateway Protocol)** associé à **EVPN (Ethernet VPN)** est une solution moderne pour fournir des services de connectivité réseau de niveau 2 (L2) et de niveau 3 (L3) sur des infrastructures IP/MPLS.
### Concepts clés :
- **BGP (Border Gateway Protocol)** : Protocole de routage utilisé pour échanger des informations de routage entre différents systèmes autonomes (AS). Il est extensible et supporte plusieurs familles d'adresses, y compris EVPN.
- **EVPN (Ethernet VPN)** : Une extension de BGP qui permet de transporter des informations de réseau Ethernet (L2) et IP (L3) sur un réseau sous-jacent. Elle est souvent utilisée avec VXLAN pour créer des réseaux overlay.
- **L2 (Niveau 2)** : Correspond à la couche de liaison de données dans le modèle OSI. Elle gère les communications entre dispositifs sur le même réseau local (LAN) et utilise des adresses MAC pour identifier les appareils.
- **L3 (Niveau 3)** : Correspond à la couche réseau dans le modèle OSI. Elle gère le routage des paquets entre différents réseaux en utilisant des adresses IP.
- **VTEP (Virtual Tunnel Endpoint)** : Point de terminaison d'un tunnel VXLAN, utilisé pour encapsuler et décapsuler les paquets VXLAN.
- **VNI (VXLAN Network Identifier)** : Identifiant unique utilisé pour distinguer les différents réseaux overlay dans une infrastructure VXLAN.

### Fonctionnement :
1. **Annonce des VTEP (Virtual Tunnel Endpoints)** :
  - Les routeurs ou commutateurs configurés avec EVPN annoncent leurs adresses IP (VTEP) via BGP.
  - Ces annonces permettent de découvrir dynamiquement les points de terminaison des tunnels VXLAN.

2. **Apprentissage des adresses MAC et IP** :
  - Les informations sur les adresses MAC et IP des hôtes connectés sont propagées via EVPN.
  - Cela élimine le besoin de flooding traditionnel pour découvrir les adresses MAC.

3. **Routage et Pontage simultanés** :
  - EVPN permet de gérer à la fois le routage (L3) et le pontage (L2) sur le même réseau.
  - Cela simplifie la gestion des réseaux hybrides.

4. **Redondance et Équilibrage de charge** :
  - Grâce à BGP, EVPN offre une redondance efficace et un équilibrage de charge entre les différents chemins disponibles.

### Avantages :
- **Scalabilité** : EVPN est conçu pour gérer de grands réseaux overlay avec des milliers de points de terminaison.
- **Efficacité** : Réduit le flooding et le broadcast en utilisant des annonces contrôlées via BGP.
- **Interopérabilité** : Fonctionne sur des infrastructures IP existantes, sans nécessiter de matériel spécialisé.
- **Flexibilité** : Permet une segmentation réseau avancée grâce à l'utilisation de VNI (VXLAN Network Identifiers).

### Intégration dans les configurations fournies :
Dans les configurations des routeurs, EVPN est activé dans la famille d'adresses `l2vpn evpn` de BGP. Voici les points importants :
- Les voisins BGP échangent des informations sur les VNI et les routes associées.
- Les interfaces loopback (`lo`) sont utilisées comme source des mises à jour BGP, garantissant une connectivité stable.
- Les annonces EVPN permettent une connectivité transparente entre les différents routeurs, tout en assurant une redondance et un équilibrage de charge.

Cette configuration illustre comment EVPN, combiné à BGP, peut être utilisé pour construire un réseau overlay robuste et évolutif, adapté aux besoins modernes des centres de données et des réseaux d'entreprise.
<details>
<summary> Routeur Configuration 1</summary>

```bash
vtysh
```
- **Explication :** Lance l'interface de configuration FRR (`vtysh`).

---

```bash
config terminal
```
- **Explication :** Passe en mode de configuration globale.

---

```bash
hostname routeur-hbelle-1
```
- **Explication :** Définit le nom du routeur.

---

```bash
no ipv6 forwarding
```
- **Explication :** Désactive le routage IPv6.

---

```bash
interface eth0
ip address 10.1.1.1/30
```
- **Explication :** Configure l'interface `eth0` avec l'adresse IP `10.1.1.1/30`.

---

```bash
interface eth1
ip address 10.1.1.5/30
```
- **Explication :** Configure l'interface `eth1` avec l'adresse IP `10.1.1.5/30`.

---

```bash
interface eth2
ip address 10.1.1.9/30
```
- **Explication :** Configure l'interface `eth2` avec l'adresse IP `10.1.1.9/30`.

---

```bash
interface lo
ip address 1.1.1.1/32
```
- **Explication :** Configure l'interface de loopback (`lo`) avec l'adresse IP `1.1.1.1/32`.

---

```bash
router bgp 1
neighbor ibgp peer-group
neighbor ibgp remote-as 1
neighbor ibgp update-source lo
bgp listen range 1.1.1.0/29 peer-group ibgp
```
- **Explication :**
  - Active le protocole BGP avec l'AS (Autonomous System) `1`.
  - Configure un groupe de voisins BGP nommé `ibgp`.
  - Définit l'AS distant comme `1` pour le groupe `ibgp`.
  - Configure l'interface de loopback (`lo`) comme source des mises à jour BGP.
  - Écoute les voisins dans la plage d'adresses `1.1.1.0/29` et les associe au groupe `ibgp`.

---

```bash
address-family l2vpn evpn
neighbor ibgp activate
neighbor ibgp route-reflector-client
exit-address-family
```
- **Explication :**
  - Active la famille d'adresses `l2vpn evpn` pour le groupe de voisins `ibgp`.
  - Configure les voisins comme clients du routeur réflecteur de routes.

---

```bash
router ospf
```
- **Explication :** Active le protocole OSPF (Open Shortest Path First) pour le routage.

</details>

---

<details>
<summary> Routeur Configuration 2</summary>

```bash
ip link add br0 type bridge
```
- **Explication :** Crée une interface de type pont (`bridge`) appelée `br0`. Un pont réseau permet de relier plusieurs interfaces réseau pour qu'elles fonctionnent comme une seule.

---

```bash
ip link set dev br0 up
```
- **Explication :** Active l'interface `br0`.

---

```bash
ip link add vxlan10 type vxlan id 10 dstport 4789
```
- **Explication :** Crée une interface VXLAN nommée `vxlan10` avec :
  - `id 10` : Identifiant VXLAN (VXLAN ID).
  - `dstport 4789` : Port de destination par défaut pour VXLAN.

---

```bash
ip link set dev vxlan10 up
```
- **Explication :** Active l'interface `vxlan10`.

---

```bash
brctl addif br0 vxlan10
```
- **Explication :** Ajoute l'interface `vxlan10` au pont `br0`.

---

```bash
brctl addif br0 eth0
```
- **Explication :** Ajoute l'interface `eth0` au pont `br0`.

---

```bash
vtysh
```
- **Explication :** Lance l'interface de configuration FRR (`vtysh`).

---

```bash
config terminal
```
- **Explication :** Passe en mode de configuration globale.

---

```bash
hostname routeur-hbelle-2
```
- **Explication :** Définit le nom du routeur.

---

```bash
no ipv6 forwarding
```
- **Explication :** Désactive le routage IPv6.

---

```bash
interface eth0
ip address 10.1.1.2/30
ip ospf area 0
```
- **Explication :**
  - Configure l'interface `eth0` avec l'adresse IP `10.1.1.2/30`.
  - Ajoute l'interface à la zone OSPF `0`.

---

```bash
interface lo
ip address 1.1.1.2/32
ip ospf area 0
```
- **Explication :**
  - Configure l'interface de loopback (`lo`) avec l'adresse IP `1.1.1.2/32`.
  - Ajoute l'interface à la zone OSPF `0`.

---

```bash
router bgp 1
neighbor 1.1.1.1 remote-as 1
neighbor 1.1.1.1 update-source lo
```
- **Explication :**
  - Active le protocole BGP avec l'AS (Autonomous System) `1`.
  - Configure un voisin BGP avec l'adresse IP `1.1.1.1` et l'AS distant `1`.
  - Définit l'interface de loopback (`lo`) comme source des mises à jour BGP.

---

```bash
address-family l2vpn evpn
neighbor 1.1.1.1 activate
advertise-all-vni
exit-address-family
```
- **Explication :**
  - Active la famille d'adresses `l2vpn evpn` pour le voisin `1.1.1.1`.
  - Configure l'annonce de tous les VNI (VXLAN Network Identifiers).

---

```bash
router ospf
```
- **Explication :** Active le protocole OSPF (Open Shortest Path First) pour le routage.

</details>

---

<details>
<summary> Routeur Configuration 3</summary>

```bash
vtysh
```
- **Explication :** Lance l'interface de configuration FRR (`vtysh`).

---

```bash
config terminal
```
- **Explication :** Passe en mode de configuration globale.

---

```bash
hostname routeur-hbelle-3
```
- **Explication :** Définit le nom du routeur.

---

```bash
no ipv6 forwarding
```
- **Explication :** Désactive le routage IPv6.

---

```bash
interface eth0
ip address 10.1.1.6/30
ip ospf area 0
```
- **Explication :**
  - Configure l'interface `eth0` avec l'adresse IP `10.1.1.6/30`.
  - Ajoute l'interface à la zone OSPF `0`.

---

```bash
interface lo
ip address 1.1.1.3/32
ip ospf area 0
```
- **Explication :**
  - Configure l'interface de loopback (`lo`) avec l'adresse IP `1.1.1.3/32`.
  - Ajoute l'interface à la zone OSPF `0`.

---

```bash
router bgp 1
neighbor 1.1.1.1 remote-as 1
neighbor 1.1.1.1 update-source lo
```
- **Explication :**
  - Active le protocole BGP avec l'AS (Autonomous System) `1`.
  - Configure un voisin BGP avec l'adresse IP `1.1.1.1` et l'AS distant `1`.
  - Définit l'interface de loopback (`lo`) comme source des mises à jour BGP.

---

```bash
address-family l2vpn evpn
neighbor 1.1.1.1 activate
advertise-all-vni
exit-address-family
```
- **Explication :**
  - Active la famille d'adresses `l2vpn evpn` pour le voisin `1.1.1.1`.
  - Configure l'annonce de tous les VNI (VXLAN Network Identifiers).

---

```bash
router ospf
```
- **Explication :** Active le protocole OSPF (Open Shortest Path First) pour le routage.

</details>

---

<details>
<summary> Routeur Configuration 4</summary>

```bash
ip link add br0 type bridge
```
- **Explication :** Crée une interface de type pont (`bridge`) appelée `br0`. Un pont réseau permet de relier plusieurs interfaces réseau pour qu'elles fonctionnent comme une seule.

---

```bash
ip link set dev br0 up
```
- **Explication :** Active l'interface `br0`.

---

```bash
ip link add vxlan10 type vxlan id 10 dstport 4789
```
- **Explication :** Crée une interface VXLAN nommée `vxlan10` avec :
  - `id 10` : Identifiant VXLAN (VXLAN ID).
  - `dstport 4789` : Port de destination par défaut pour VXLAN.

---

```bash
ip link set dev vxlan10 up
```
- **Explication :** Active l'interface `vxlan10`.

---

```bash
brctl addif br0 vxlan10
```
- **Explication :** Ajoute l'interface `vxlan10` au pont `br0`.

---

```bash
brctl addif br0 eth0
```
- **Explication :** Ajoute l'interface `eth0` au pont `br0`.

---

```bash
vtysh
```
- **Explication :** Lance l'interface de configuration FRR (`vtysh`).

---

```bash
config terminal
```
- **Explication :** Passe en mode de configuration globale.

---

```bash
hostname routeur-hbelle-4
```
- **Explication :** Définit le nom du routeur.

---

```bash
no ipv6 forwarding
```
- **Explication :** Désactive le routage IPv6.

---

```bash
interface eth0
ip address 10.1.1.10/30
ip ospf area 0
```
- **Explication :**
  - Configure l'interface `eth0` avec l'adresse IP `10.1.1.10/30`.
  - Ajoute l'interface à la zone OSPF `0`.

---

```bash
interface lo
ip address 1.1.1.4/32
ip ospf area 0
```
- **Explication :**
  - Configure l'interface de loopback (`lo`) avec l'adresse IP `1.1.1.4/32`.
  - Ajoute l'interface à la zone OSPF `0`.

---

```bash
router bgp 1
neighbor 1.1.1.1 remote-as 1
neighbor 1.1.1.1 update-source lo
```
- **Explication :**
  - Active le protocole BGP avec l'AS (Autonomous System) `1`.
  - Configure un voisin BGP avec l'adresse IP `1.1.1.1` et l'AS distant `1`.
  - Définit l'interface de loopback (`lo`) comme source des mises à jour BGP.

---

```bash
address-family l2vpn evpn
neighbor 1.1.1.1 activate
advertise-all-vni
exit-address-family
```
- **Explication :**
  - Active la famille d'adresses `l2vpn evpn` pour le voisin `1.1.1.1`.
  - Configure l'annonce de tous les VNI (VXLAN Network Identifiers).

---

```bash
router ospf
```
- **Explication :** Active le protocole OSPF (Open Shortest Path First) pour le routage.

</details>
