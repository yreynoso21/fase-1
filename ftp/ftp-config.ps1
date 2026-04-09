# ============================================================
#  SERVIDOR FTP - servidor1.com
#  Practicas Iniciales - USAC Ingenieria
#  Punto 8: File Transfer Protocol
# ============================================================

# ── 1. Instalar FTP en IIS ───────────────────────────────────
Install-WindowsFeature -Name Web-Ftp-Server, Web-Ftp-Service `
    -IncludeManagementTools

Import-Module WebAdministration

Write-Host "FTP instalado correctamente." -ForegroundColor Green

# ── 2. Crear carpeta raiz del FTP ────────────────────────────
New-Item -Path "C:\FTP" -ItemType Directory -Force

# Subcarpeta publica accesible para usuario1 y usuario2
New-Item -Path "C:\FTP\publica" -ItemType Directory -Force

Write-Host "Carpeta C:\FTP creada." -ForegroundColor Green

# ── 3. Crear sitio FTP en IIS ────────────────────────────────
New-WebFtpSite `
    -Name "ServidorFTP" `
    -Port 21 `
    -PhysicalPath "C:\FTP" `
    -Force

# ── 4. Configurar autenticacion ──────────────────────────────
# Deshabilitar acceso anonimo
Set-WebConfigurationProperty `
    -Filter "system.ftpServer/security/authentication/anonymousAuthentication" `
    -Name "enabled" `
    -Value $false `
    -PSPath "IIS:\Sites\ServidorFTP"

# Habilitar autenticacion basica (usuario y contrasena)
Set-WebConfigurationProperty `
    -Filter "system.ftpServer/security/authentication/basicAuthentication" `
    -Name "enabled" `
    -Value $true `
    -PSPath "IIS:\Sites\ServidorFTP"

# ── 5. Dar acceso FTP a usuario1 y usuario2 ──────────────────
# Regla: usuarios autenticados tienen acceso de lectura y escritura

Add-WebConfiguration `
    -Filter "system.ftpServer/security/authorization" `
    -Value @{
        accessType = "Allow"
        users      = "usuario1,usuario2"
        permissions = "Read,Write"
    } `
    -PSPath "IIS:\Sites\ServidorFTP"

Write-Host "usuario1 y usuario2 tienen acceso FTP (lectura y escritura)." -ForegroundColor Green

# ── 6. Permisos de carpeta para usuario1 y usuario2 ──────────
$ACL = Get-Acl "C:\FTP"

$ReglaU1 = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "usuario1", "Modify", "ContainerInherit,ObjectInherit", "None", "Allow"
)
$ReglaU2 = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "usuario2", "Modify", "ContainerInherit,ObjectInherit", "None", "Allow"
)

$ACL.AddAccessRule($ReglaU1)
$ACL.AddAccessRule($ReglaU2)
Set-Acl -Path "C:\FTP" -AclObject $ACL

# ── 7. Acceso a carpeta publica ──────────────────────────────
# Ambos usuarios tienen privilegios sobre la carpeta publica

$ACLPublica = Get-Acl "C:\FTP\publica"
$ACLPublica.AddAccessRule($ReglaU1)
$ACLPublica.AddAccessRule($ReglaU2)
Set-Acl -Path "C:\FTP\publica" -AclObject $ACLPublica

Write-Host "Permisos de carpeta publica asignados a usuario1 y usuario2." -ForegroundColor Green

# ── 8. Iniciar el sitio FTP ──────────────────────────────────
Start-Website -Name "ServidorFTP"

# ── 9. Abrir puerto 21 en el Firewall ────────────────────────
New-NetFirewallRule -DisplayName "FTP Puerto 21" -Direction Inbound -Protocol TCP -LocalPort 21 -Action Allow

# Puerto para FTP pasivo (rango tipico)
New-NetFirewallRule -DisplayName "FTP Pasivo" -Direction Inbound -Protocol TCP -LocalPort 1024-65535 -Action Allow

Write-Host "=== Servidor FTP configurado correctamente ===" -ForegroundColor Cyan
Write-Host "Conexion FTP: ftp://192.168.0.10" -ForegroundColor Yellow
Write-Host "Usuarios habilitados: usuario1 / usuario2 (contrasena: password)"
