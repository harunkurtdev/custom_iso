#!/bin/sh

# Ubuntu Autoinstall HTTP Server
# Serves dynamic configuration files for cloud-init

echo "Starting Ubuntu Autoinstall HTTP Server..."

# Copy configuration files to web root
if [ -d /app/configs ]; then
    echo "Copying configuration files..."
    cp -r /app/configs/* /var/www/html/ 2>/dev/null || true
fi

# Create a simple index page
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Ubuntu Autoinstall Server</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .header { color: #333; }
        .endpoint { background: #f5f5f5; padding: 10px; margin: 10px 0; border-radius: 5px; }
        .code { font-family: monospace; background: #eee; padding: 2px 4px; }
    </style>
</head>
<body>
    <h1 class="header">Ubuntu Autoinstall Configuration Server</h1>
    <p>This server provides dynamic configuration files for Ubuntu Server autoinstall.</p>
    
    <h2>Available Endpoints:</h2>
    <div class="endpoint">
        <strong>Meta-data:</strong> <span class="code">GET /meta-data</span><br>
        Provides cloud-init meta-data configuration
    </div>
    
    <div class="endpoint">
        <strong>User-data:</strong> <span class="code">GET /user-data[?hw=HARDWARE]</span><br>
        Provides cloud-init user-data configuration<br>
        Hardware options: up2, apu, apu2
    </div>
    
    <div class="endpoint">
        <strong>All configs:</strong> <span class="code">GET /configs/</span><br>
        Browse all available configuration files
    </div>
    
    <div class="endpoint">
        <strong>Health check:</strong> <span class="code">GET /health</span><br>
        Server health status
    </div>
    
    <h2>Usage Examples:</h2>
    <ul>
        <li>Ubuntu installer: <span class="code">ds=nocloud-net;s=http://SERVER_IP:8080/</span></li>
        <li>Hardware-specific: <span class="code">ds=nocloud-net;s=http://SERVER_IP:8080/?hw=up2</span></li>
    </ul>
    
    <p><em>Server started at $(date)</em></p>
</body>
</html>
EOF

echo "Configuration server ready!"
echo "Available endpoints:"
echo "  - GET /meta-data"
echo "  - GET /user-data[?hw=HARDWARE]"
echo "  - GET /configs/"
echo "  - GET /health"

# Start nginx
exec nginx -g 'daemon off;'