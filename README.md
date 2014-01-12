vhostd
======
Virtualhost proxy server

# Install
    sudo npm install -g vhostd

# Edit configuration file:
    sudo nano /etc/vhostd.json
## Example config.json:
    {
      "port": 80,
      "targets": {
        "127.0.0.1:8080": "unique.project.com",
        "127.0.0.1:9080": ["www.coolstuff.com", "coolstuff.com"]
      }
    }

# Run
    sudo vhostd
