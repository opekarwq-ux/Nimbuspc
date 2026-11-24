# Nimbus PC: deixa o Windows pronto no primeiro boot (visual roxo, ícones e programas).
$ErrorActionPreference = "SilentlyContinue"

# --- Visual: tema escuro e cor de destaque roxa (usuário atual e novos usuários) ---
function Set-Look($hive) {
  reg add "$hive\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v AppsUseLightTheme /t REG_DWORD /d 0 /f | Out-Null
  reg add "$hive\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v SystemUsesLightTheme /t REG_DWORD /d 0 /f | Out-Null
  reg add "$hive\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v ColorPrevalence /t REG_DWORD /d 1 /f | Out-Null
  reg add "$hive\Software\Microsoft\Windows\DWM" /v AccentColor /t REG_DWORD /d 0xffff3d9b /f | Out-Null
  reg add "$hive\Software\Microsoft\Windows\DWM" /v ColorPrevalence /t REG_DWORD /d 1 /f | Out-Null
  # Ícones da área de trabalho: Este Computador e Lixeira
  foreach ($g in "{20D04FE0-3AEA-1069-A2D8-08002B30309D}", "{645FF040-5081-101B-9F08-00AA002F954E}") {
    reg add "$hive\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v $g /t REG_DWORD /d 0 /f | Out-Null
  }
}
Set-Look "HKCU"
reg load HKU\NimbusDef "C:\Users\Default\NTUSER.DAT" | Out-Null
Set-Look "HKU\NimbusDef"
[gc]::Collect(); reg unload HKU\NimbusDef | Out-Null

# --- Atalhos na área de trabalho (todos os usuários) ---
$ws = New-Object -ComObject WScript.Shell
function Link($name, $target, $arguments) {
  $s = $ws.CreateShortcut("$env:PUBLIC\Desktop\$name.lnk"); $s.TargetPath = $target
  if ($arguments) { $s.Arguments = $arguments }; $s.Save()
}
Link "Gerenciador de Tarefas" "$env:WINDIR\System32\Taskmgr.exe"
Link "Bloco de Notas" "$env:WINDIR\System32\notepad.exe"
Link "Calculadora" "$env:WINDIR\System32\calc.exe"
Link "Terminal" "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe"
Link "Configurações" "$env:WINDIR\explorer.exe" "ms-settings:"
Link "Microsoft Edge" "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"

# --- Programas (Chocolatey): Chrome, Steam, Discord e Spotify ---
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = 3072
iex ((New-Object System.Net.WebClient).DownloadString("https://community.chocolatey.org/install.ps1"))
$env:Path += ";$env:ALLUSERSPROFILE\chocolatey\bin"
choco install -y googlechrome steam-client discord spotify
