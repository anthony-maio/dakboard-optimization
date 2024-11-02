# Web Server (Lighttpd) Configuration Reference

## Overview
The Lighttpd web server configuration optimizes performance for DAKboard's web interface and ensures proper PHP handling through FastCGI.

## File Location
```bash
/etc/lighttpd/lighttpd.conf
```

## Core Settings

### Basic Server Configuration
```nginx
# Server settings
server.document-root        = "/var/www/html"
server.upload-dirs         = ( "/var/cache/lighttpd/uploads" )
server.errorlog            = "/var/log/lighttpd/error.log"
server.pid-file           = "/run/lighttpd.pid"
server.username           = "www-data"
server.groupname          = "www-data"
server.port               = 80
```

### Performance Optimization
```nginx
# Performance tuning
server.max-keep-alive-requests = 100
server.max-keep-alive-idle    = 30
server.max-read-idle         = 60
server.max-write-idle        = 360
server.max-worker            = 4
static-file.etags            = "enable"
server.network-backend      = "sendfile"
```

### Module Loading
```nginx
server.modules = (
    "mod_auth",
    "mod_access",
    "mod_alias",
    "mod_compress",
    "mod_redirect",
    "mod_rewrite",
    "mod_fastcgi",
    "mod_setenv"
)
```

## FastCGI Configuration

### PHP Handler
```nginx
fastcgi.server = ( ".php" =>
    ((
        "socket" => "/var/run/php/php-fcgi.socket",
        "bin-path" => "/usr/bin/php-cgi",
        "max-procs" => 4,
        "idle-timeout" => 20,
        "bin-environment" => (
            "PHP_FCGI_CHILDREN" => "4",
            "PHP_FCGI_MAX_REQUESTS" => "10000"
        )
    ))
)
```

### Compression Settings
```nginx
compress.cache-dir          = "/var/cache/lighttpd/compress/"
compress.filetype          = (
    "application/javascript",
    "text/css",
    "text/html",
    "text/plain",
    "text/xml",
    "application/json"
)
```

## Security Configuration

### Basic Security
```nginx
# Deny access to sensitive files
url.access-deny = ( "~", ".inc", ".md", ".sql", ".conf" )

# Directory listing
dir-listing.activate = "disable"
```

### Security Headers
```nginx
setenv.add-response-header = (
    "X-Frame-Options" => "SAMEORIGIN",
    "X-Content-Type-Options" => "nosniff",
    "X-XSS-Protection" => "1; mode=block",
    "Referrer-Policy" => "strict-origin-when-cross-origin"
)
```

## Caching Configuration

### Static Content
```nginx
# Cache static content
$HTTP["url"] =~ "\.(jpg|jpeg|gif|png|css|js)$" {
    expire.url = ( "" => "access plus 1 months" )
}
```

### Dynamic Content
```nginx
# No cache for PHP files
$HTTP["url"] =~ "\.php$" {
    expire.url = ( "" => "access plus 0 seconds" )
}
```

## Verification

### Config Test
```bash
# Test configuration
lighttpd -t -f /etc/lighttpd/lighttpd.conf

# Check service status
systemctl status lighttpd

# Check FastCGI processes
ps aux | grep php-cgi
```

### Log Monitoring
```bash
# Check error log
tail -f /var/log/lighttpd/error.log

# Check access log
tail -f /var/log/lighttpd/access.log
```

## Common Issues

### FastCGI Problems
```bash
# Restart PHP-CGI
killall php-cgi
systemctl restart lighttpd

# Check socket
ls -l /var/run/php/php-fcgi.socket
```

### Permission Issues
```bash
# Fix permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html
```

## Performance Tuning

### Memory Usage
```nginx
# Adjust based on available RAM
fastcgi.server = ( ".php" =>
    ((
        "max-procs" => 4,        # Reduce if low on memory
        "idle-timeout" => 20,    # Increase if high traffic
        "PHP_FCGI_CHILDREN" => "4"
    ))
)
```

### Connection Handling
```nginx
# Adjust for performance
server.max-keep-alive-requests = 100  # Higher for busy servers
server.max-keep-alive-idle = 30      # Lower for more responsive cleanup
```

## Monitoring Commands
```bash
# Check running processes
ps aux | grep lighttpd
ps aux | grep php-cgi

# Check open files
lsof -i :80

# Monitor connections
netstat -tunap | grep lighttpd
```
