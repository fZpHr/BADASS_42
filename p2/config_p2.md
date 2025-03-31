# Network Configuration Guide

Ce document fournit un guide étape par étape pour configurer un pont réseau et une interface VXLAN (Virtual Extensible LAN).

## Différence entre multicast statique et multicast dynamique

### Multicast Statique
Le multicast statique implique une configuration manuelle des adresses IP des pairs distants. Cela signifie que chaque routeur ou périphérique doit être configuré avec les adresses IP des autres participants au VXLAN. Cette méthode est simple mais peu évolutive, car toute modification dans le réseau nécessite une mise à jour manuelle de la configuration.

### Multicast Dynamique
Le multicast dynamique utilise un groupe multicast (par exemple, `239.1.1.1`) pour diffuser les paquets VXLAN. Les périphériques rejoignent automatiquement ce groupe multicast, ce qui permet une découverte automatique des pairs. Cette méthode est plus adaptée aux environnements dynamiques ou de grande échelle, mais elle nécessite que le réseau sous-jacent prenne en charge le multicast.

---

## Part 1 - Multicast Statique

### Étapes pour configurer le réseau

#### 1. Créer et activer l'interface bridge

- **Commande :**
    ```bash
    ip link add br0 type bridge
    ```
    - **Explication :** Cette commande crée une interface de type pont (`bridge`) appelée `br0`. Un pont réseau permet de relier plusieurs interfaces réseau pour qu'elles fonctionnent comme une seule.

- **Commande :**
    ```bash
    ip link set dev br0 up
    ```
    - **Explication :** Cette commande active l'interface `br0`.

- **Commande :**
    ```bash
    ip addr add 10.1.1.1/24 dev eth0
    ```
    - **Explication :** Cette commande attribue l'adresse IP `10.1.1.1` avec un masque de sous-réseau `/24` à l'interface `eth0`.

#### 2. Vérifier l'interface `eth0`

- **Commande :**
    ```bash
    ip addr show eth0
    ```
    - **Explication :** Affiche les informations détaillées sur l'interface `eth0`, y compris son adresse IP.

#### 3. Créer l'interface VXLAN

- **Commande :**
    ```bash
    ip link add name vxlan10 type vxlan id 10 dev eth0 remote 10.1.1.2 local 10.1.1.1 dstport 4789
    ```
    - **Explication :**
        - `name vxlan10` : Nom de l'interface VXLAN.
        - `type vxlan` : Spécifie que l'interface est de type VXLAN.
        - `id 10` : Identifiant VXLAN (VXLAN ID).
        - `dev eth0` : Interface sous-jacente utilisée pour transporter le trafic VXLAN.
        - `remote 10.1.1.2` : Adresse IP distante (pair VXLAN).
        - `local 10.1.1.1` : Adresse IP locale.
        - `dstport 4789` : Port de destination par défaut pour VXLAN.

#### 4. Attribuer une adresse IP à l'interface VXLAN

- **Commande :**
    ```bash
    ip addr add 20.1.1.1/24 dev vxlan10
    ```
    - **Explication :** Attribue l'adresse IP `20.1.1.1` avec un masque `/24` à l'interface `vxlan10`.

#### 5. Vérifier l'interface VXLAN

- **Commande :**
    ```bash
    ip -d link show vxlan10
    ```
    - **Explication :** Affiche des informations détaillées sur l'interface `vxlan10`, y compris les paramètres VXLAN.

#### 6. Ajouter des interfaces au pont

- **Commandes :**
    ```bash
    brctl addif br0 eth1
    brctl addif br0 vxlan10
    ip link set dev vxlan10 up
    ```
    - **Explication :**
        - `brctl addif br0 eth1` : Ajoute l'interface `eth1` au pont `br0`.
        - `brctl addif br0 vxlan10` : Ajoute l'interface `vxlan10` au pont `br0`.
        - `ip link set dev vxlan10 up` : Active l'interface `vxlan10`.

#### 7. Vérifier les interfaces

- **Commandes :**
    ```bash
    ip -d link show vxlan10
    ip link show vxlan10
    ip link show eth1
    ```
    - **Explication :** Ces commandes affichent des informations détaillées sur les interfaces `vxlan10` et `eth1`.

#### 8. Configurer le second routeur

- **Commandes qui change pour le second routeur :**
        ```bash
        ip addr add 10.1.1.2/24 dev eth0
        ip link add name vxlan10 type vxlan id 10 dev eth0 remote 10.1.1.1 local 10.1.1.2 dstport 4789
        ```
        - **Explication :**
                - `ip addr add 10.1.1.2/24 dev eth0` : Attribue l'adresse IP `10.1.1.2` avec un masque `/24` à l'interface `eth0`.
                - `ip link add name vxlan10 type vxlan id 10 dev eth0 remote 10.1.1.1 local 10.1.1.2 dstport 4789` : Inverse les adresses `remote` et `local` pour établir la connectivité entre les deux routeurs.

#### 9. Configurer les hôtes

Pour l'Hôte 1 :
- Assigner l'adresse IP `30.1.1.1/24` à l'interface `eth1` :
    ```bash
    ip addr add 30.1.1.1/24 dev eth1
    ```

Pour l'Hôte 2 :
- Assigner l'adresse IP `30.1.1.2/24` à l'interface `eth1` :
    ```bash
    ip addr add 30.1.1.2/24 dev eth1
    ```

---

## Part 2 - Multicast Dynamique

### Étapes pour configurer le réseau

#### 1. Créer et activer l'interface bridge

- **Commandes :**
    ```bash
    ip link add br0 type bridge
    ip link set dev br0 up
    ip addr add 10.1.1.1/24 dev eth0
    ```
    - **Explication :** Identique à la configuration statique.

#### 2. Créer l'interface VXLAN

- **Commande :**
    ```bash
    ip link add name vxlan10 type vxlan id 10 dev eth0 group 239.1.1.1 dstport 4789
    ```
    - **Explication :**
        - `group 239.1.1.1` : Spécifie le groupe multicast utilisé pour la découverte automatique des pairs.

#### 3. Vérifier l'interface VXLAN

- **Commande :**
    ```bash
    ip -d link show vxlan10
    ```
    - **Explication :** Vérifie les paramètres de l'interface VXLAN.

#### 4. Ajouter des interfaces au pont

- **Commandes :**
    ```bash
    brctl addif br0 eth1
    brctl addif br0 vxlan10
    ip link set dev vxlan10 up
    ```
    - **Explication :** Identique à la configuration statique.

#### 5. Configurer le second routeur

- **Commande pour le second routeur :**
    ```bash
    ip link add name vxlan10 type vxlan id 10 dev eth0 group 239.1.1.1 dstport 4789
    ```
    - **Explication :** Le second routeur rejoint automatiquement le groupe multicast.

#### 6. Configurer les hôtes

Pour l'Hôte 1 :
- Assigner l'adresse IP `30.1.1.1/24` à l'interface `eth1` :
    ```bash
    ip addr add 30.1.1.1/24 dev eth1
    ```

Pour l'Hôte 2 :
- Assigner l'adresse IP `30.1.1.2/24` à l'interface `eth1` :
    ```bash
    ip addr add 30.1.1.2/24 dev eth1
    ```

---

## Vérification de la connectivité

- **Commandes :**
    ```bash
    ping 30.1.1.2
    ```
    - **Explication :** Teste la connectivité entre les hôtes via le VXLAN.

- **Wireshark :** Utilisez Wireshark pour vérifier que les paquets ICMP sont encapsulés dans VXLAN et transmis correctement.

---

