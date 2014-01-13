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
    sudo vhostd [start|stop|restart|status]
Run without a task directive and it will attempt a soft start - e.g. will not
restart if there is a process already running.

# Log
    /var/log/vhostd
