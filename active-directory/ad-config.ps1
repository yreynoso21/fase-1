# ============================================================
#  ACTIVE DIRECTORY - servidor1.com
#  Practicas Iniciales - USAC Ingenieria
#  Punto 2: Servidor de Usuarios
# ============================================================

# ── 1. Instalar rol de Active Directory ──────────────────────
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# ── 2. Promover el servidor a Controlador de Dominio ─────────
Import-Module ADDSDeployment

Install-ADDSForest `
    -DomainName "servidor1.com" `
    -DomainNetbiosName "SERVIDOR1" `
    -SafeModeAdministratorPassword (ConvertTo-SecureString "Admin@1234" -AsPlainText -Force) `
    -InstallDns `
    -Force

# NOTA: El servidor se reiniciará automaticamente.
# Ejecuta el resto del script DESPUES del reinicio.

# ── 3. Crear Unidad Organizativa (OU) ────────────────────────
New-ADOrganizationalUnit `
    -Name "UsuariosDominio" `
    -Path "DC=servidor1,DC=com" `
    -ProtectedFromAccidentalDeletion $false

# ── 4. Crear usuario1 ────────────────────────────────────────
New-ADUser `
    -Name "usuario1" `
    -GivenName "Usuario" `
    -Surname "Uno" `
    -SamAccountName "usuario1" `
    -UserPrincipalName "usuario1@servidor1.com" `
    -Path "OU=UsuariosDominio,DC=servidor1,DC=com" `
    -AccountPassword (ConvertTo-SecureString "password" -AsPlainText -Force) `
    -Enabled $true `
    -PasswordNeverExpires $true

# ── 5. Crear usuario2 ────────────────────────────────────────
New-ADUser `
    -Name "usuario2" `
    -GivenName "Usuario" `
    -Surname "Dos" `
    -SamAccountName "usuario2" `
    -UserPrincipalName "usuario2@servidor1.com" `
    -Path "OU=UsuariosDominio,DC=servidor1,DC=com" `
    -AccountPassword (ConvertTo-SecureString "password" -AsPlainText -Force) `
    -Enabled $true `
    -PasswordNeverExpires $true

Write-Host "Usuarios creados: usuario1 y usuario2" -ForegroundColor Green

# ── 6. Politica de Grupo (GPO) ───────────────────────────────
# Se crea una GPO global para todos los usuarios del dominio

Import-Module GroupPolicy

# Crear la GPO
New-GPO -Name "PoliticaGlobalDominio" -Comment "GPO global - Practicas Iniciales"

# Vincular la GPO al dominio completo
New-GPLink `
    -Name "PoliticaGlobalDominio" `
    -Target "DC=servidor1,DC=com"

# ── 6.1 Fondo de pantalla con logo de la universidad ─────────
# IMPORTANTE: Coloca el logo en C:\Windows\SYSVOL\sysvol\servidor1.com\logo_usac.jpg
# antes de ejecutar esta parte.

$GPOName = "PoliticaGlobalDominio"
$WallpaperPath = "C:\Windows\SYSVOL\sysvol\servidor1.com\logo_usac.jpg"

Set-GPRegistryValue `
    -Name $GPOName `
    -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" `
    -ValueName "Wallpaper" `
    -Type String `
    -Value $WallpaperPath

Set-GPRegistryValue `
    -Name $GPOName `
    -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" `
    -ValueName "WallpaperStyle" `
    -Type String `
    -Value "2"

# Deshabilitar que el usuario cambie el fondo de pantalla
Set-GPRegistryValue `
    -Name $GPOName `
    -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop" `
    -ValueName "NoChangingWallPaper" `
    -Type DWord `
    -Value 1

# ── 6.2 Politica adicional util: Deshabilitar acceso al Panel de Control ──
# (Reemplaza la politica de IE que ya no aplica en Server 2012+)
Set-GPRegistryValue `
    -Name $GPOName `
    -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
    -ValueName "NoControlPanel" `
    -Type DWord `
    -Value 1

Write-Host "GPO 'PoliticaGlobalDominio' creada y vinculada al dominio." -ForegroundColor Green
Write-Host "Recuerda copiar el logo_usac.jpg a C:\Windows\SYSVOL\sysvol\servidor1.com\" -ForegroundColor Yellow

# ── 7. Forzar actualizacion de politicas ─────────────────────
Invoke-GPUpdate -Force

Write-Host "=== Active Directory configurado correctamente ===" -ForegroundColor Cyan
