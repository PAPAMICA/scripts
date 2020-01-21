
# Scripts by PAPAMICA
|  ![PAPAMICA](https://zupimages.net/up/20/04/7vtd.png) |  [Labo-Tech.fr](https://labo-tech.fr/)<br/> [Tech2Tech.fr](https://www.tech2tech.fr/) <br/> [Twitter @PAPAMICA__](https://twitter.com/PAPAMICA__) <br/> [LinkedIn](https://www.linkedin.com/in/mickael-asseline/)<br/> |
|:--------:| :-------------|

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
    
## Quelques commandes utiles :

Vu le nombre de personnes qui m’ont contacté suite aux précédents articles sur Tech2Tech.fr et Labo-Tech.fr  pour des commandes simples, voici celles que l’on m’a le plus demandées :

-   **docker container ls** : Afficher les containers Docker en cours
-   **docker-compose stop** : Arrêter les containers créés avec le scripts (dans le dossier du script)
- **docker-compose up -d** : Lancer les containers créés avec le scripts (dans le dossier du script)
-   **docker logs <id_container>** : Afficher les logs du container
-   **docker exec -it <id_container> bash** : Entrer dans le container 

Pour le reste des commandes, je vous invite à vous référer à mon article sur Labo-Tech :  [Quelles sont les commandes de base de Docker ?](https://labo-tech.fr/base-de-connaissance/quelles-sont-les-commandes-de-base-de-docker/)
