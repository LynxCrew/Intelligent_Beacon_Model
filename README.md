# Intelligented Default Bed-Mesh

## Installation
SSH into you pi and run:
```
cd ~
wget -O - https://raw.githubusercontent.com/LynxCrew/Intelligent_Beacon_Model/main/install.sh | bash
```

then add this to your moonraker.conf:
```
[update_manager intelligent_default_mesh]
type: git_repo
channel: dev
path: ~/intelligent_beacon_model
origin: https://github.com/LynxCrew/Intelligent_Beacon_Model.git
managed_services: klipper
primary_branch: main
install_script: install.sh
```

you also need to add
```
[save_variables]
filename: ~/database.cfg
```
to your printer.cfg

If you run `SET_DEFAULT_BEACON_MODEL DEFAULT_BEACON_MODEL=<name>` it will be persistently saved.
If you now run `BEACON_MODEL_SELECT NAME=default INTELLIGENT=1` instead of loading the model called 'default'
it will load the model you set beforehand.
