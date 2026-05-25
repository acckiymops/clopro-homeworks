#!/bin/bash

# Создание веб-страницы с ссылкой на картинку из бакета
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>LAMP Instance Group</title>
    <style>
        body { font-family: Arial; text-align: center; padding: 50px; }
        img { max-width: 500px; margin: 20px 0; }
    </style>
</head>
<body>
    <h1>🚀 LAMP Stack Instance Group</h1>
    <img src="${image_url}" alt="LAMP Logo">
    <p>Hostname: <?php echo gethostname(); ?></p>
    <p>IP: <?php echo \$_SERVER['SERVER_ADDR']; ?></p>
</body>
</html>
EOF

cat > /var/www/html/health <<EOF
<?php
header('Content-Type: application/json');
echo json_encode([
    'status' => 'ok',
    'hostname' => gethostname(),
    'timestamp' => date('Y-m-d H:i:s')
]);
?>
EOF

chown -R www-data: /var/www/html
systemctl restart apache2