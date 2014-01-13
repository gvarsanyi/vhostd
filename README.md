vhostd
======
Virtualhost proxy server

# Install
    sudo npm install -g vhostd

# Edit configuration file:
    sudo nano /etc/vhostd.ini
## Example config.json:
    [SERVER]
    port = 80
    
    [example.com]
    address = 127.0.0.1
    port    = 8000
    
    [alias.example.com]
    ref = example.com
    
    [other.com]
    address = 127.0.0.1
    port = 8000

# Run
    sudo vhostd
