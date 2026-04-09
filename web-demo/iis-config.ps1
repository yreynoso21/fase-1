# ============================================================
#  SERVIDOR WEB IIS - servidor1.com
#  Practicas Iniciales - USAC Ingenieria
#  Punto 6: Internet Information Server
# ============================================================

# ── 1. Instalar IIS con todas las herramientas ───────────────
Install-WindowsFeature -Name Web-Server, Web-Basic-Auth, Web-Mgmt-Console `
    -IncludeManagementTools

Import-Module WebAdministration

Write-Host "IIS instalado correctamente." -ForegroundColor Green

# ── 2. Crear carpetas fisicas ────────────────────────────────
New-Item -Path "C:\Inetpub\wwwroot\publicweb"  -ItemType Directory -Force
New-Item -Path "C:\Inetpub\wwwroot\privadaweb" -ItemType Directory -Force

# ── 3. PUBLICWEB - Acceso para todos ─────────────────────────
# Pagina principal con mensaje "Carpeta Publica"

$htmlPublico = @"
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Carpeta Publica</title>
  <style>
    body { font-family: Arial; background:#f5f5f5; text-align:center; padding:50px; }
    h1   { color:#003366; }
  </style>
</head>
<body>
  <h1>Carpeta Publica</h1>
  <p>Bienvenido al sitio publico de servidor1.com</p>
</body>
</html>
"@

Set-Content -Path "C:\Inetpub\wwwroot\publicweb\index.html" -Value $htmlPublico

# Crear aplicacion virtual en IIS (puerto 80, sin autenticacion)
New-WebVirtualDirectory `
    -Site "Default Web Site" `
    -Name "publicweb" `
    -PhysicalPath "C:\Inetpub\wwwroot\publicweb"

# Habilitar acceso anonimo
Set-WebConfigurationProperty `
    -Filter "/system.webServer/security/authentication/anonymousAuthentication" `
    -Name "enabled" `
    -Value $true `
    -PSPath "IIS:\Sites\Default Web Site\publicweb"

Write-Host "publicweb listo en http://192.168.0.20/publicweb" -ForegroundColor Green

# ── 4. PRIVADAWEB - Acceso restringido (usuario: privado) ────
# Pagina principal con mensaje "Carpeta Privada"
# Se publica en el puerto 1080

$htmlPrivado = @"
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Carpeta Privada</title>
  <style>
    body { font-family: Arial; background:#fff3f3; text-align:center; padding:50px; }
    h1   { color:#990000; }
  </style>
</head>
<body>
  <h1>Carpeta Privada</h1>
  <p>Acceso restringido - solo usuarios autorizados.</p>
</body>
</html>
"@

Set-Content -Path "C:\Inetpub\wwwroot\privadaweb\index.html" -Value $htmlPrivado

# Crear un nuevo sitio web en el puerto 1080 para privadaweb
New-Website `
    -Name "privadaweb" `
    -Port 1080 `
    -PhysicalPath "C:\Inetpub\wwwroot\privadaweb" `
    -Force

# Deshabilitar acceso anonimo en privadaweb
Set-WebConfigurationProperty `
    -Filter "/system.webServer/security/authentication/anonymousAuthentication" `
    -Name "enabled" `
    -Value $false `
    -PSPath "IIS:\Sites\privadaweb"

# Habilitar autenticacion basica
Set-WebConfigurationProperty `
    -Filter "/system.webServer/security/authentication/basicAuthentication" `
    -Name "enabled" `
    -Value $true `
    -PSPath "IIS:\Sites\privadaweb"

# Iniciar el sitio
Start-Website -Name "privadaweb"

Write-Host "privadaweb listo en http://192.168.0.20:1080/privadaweb" -ForegroundColor Green

# ── 5. CORREO - Reenvio (forward) hacia webmail ──────────────
# Carpeta virtual "correo" que redirige al webmail
# No tiene carpeta fisica - es configuracion de reenvio en IIS

New-WebVirtualDirectory `
    -Site "Default Web Site" `
    -Name "correo" `
    -PhysicalPath "C:\Inetpub\wwwroot"   # placeholder requerido

# Configurar redireccion HTTP hacia el webmail
Set-WebConfigurationProperty `
    -Filter "system.webServer/httpRedirect" `
    -Name "enabled" `
    -Value $true `
    -PSPath "IIS:\Sites\Default Web Site\correo"

Set-WebConfigurationProperty `
    -Filter "system.webServer/httpRedirect" `
    -Name "destination" `
    -Value "http://192.168.0.20/webmail" `
    -PSPath "IIS:\Sites\Default Web Site\correo"

Set-WebConfigurationProperty `
    -Filter "system.webServer/httpRedirect" `
    -Name "exactDestination" `
    -Value $true `
    -PSPath "IIS:\Sites\Default Web Site\correo"

Write-Host "correo configurado como reenvio en http://192.168.0.20/correo" -ForegroundColor Green

# ── 6. Abrir puertos en el Firewall ──────────────────────────
New-NetFirewallRule -DisplayName "IIS Puerto 80"   -Direction Inbound -Protocol TCP -LocalPort 80   -Action Allow
New-NetFirewallRule -DisplayName "IIS Puerto 1080" -Direction Inbound -Protocol TCP -LocalPort 1080 -Action Allow

Write-Host "=== Servidor Web IIS configurado correctamente ===" -ForegroundColor Cyan
Write-Host "URLs disponibles:" -ForegroundColor Yellow
Write-Host "  http://192.168.0.20/publicweb   (publica, sin contrasena)"
Write-Host "  http://192.168.0.20:1080        (privada, usuario: privado / pass: privado)"
Write-Host "  http://192.168.0.20/correo      (reenvio al webmail)"
