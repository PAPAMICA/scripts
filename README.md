# Scripts by PAPAMICA

![PAPAMICA](https://zupimages.net/up/20/04/7vtd.png)
### Fonctionnalités

- Déployez plusieurs solutions en 4 commandes : Zabbix Serveur, Zabbix Agent, Zabbix Proxy, iTop, Guacamole, et bien plus !
- Une grande partie des scripts utilisent Docker à jours avec des images à jours afin de disposer des dernières fonctionnalités.
- Les scripts fonctionnent sous différentes distributions (en fonction des dossiers).

# Debian

### Utilisation
Installation de Git :
```bash
 apt install -y git
```

Récupération des scripts :
```bash
git clone https://github.com/PAPAMICA/scripts
```


Exécuter un script :
```bash
cd scripts/debian/script_folder
chmod +x name_of_script.sh
./name_of_scripts.sh
```

### Liste des scripts

+ **Préparation VPS/VM** : debian_postinstall.sh
+ **Guacamole (Docker)** : debian_install_guacamole.sh
+ **iTop (Docker)** : debian_install_itop.sh
+ **Zabbix**
    + **Zabbix-Server (Docker)** : debian_install_zabbix_server.sh
    + **Zabbix-Proxy (Docker)** : debian_install_zabbix_proxy.sh
    + **Zabbix-Agent** : debian_install_zabbix_agent.sh
     
Et bien plus sont à venir !
