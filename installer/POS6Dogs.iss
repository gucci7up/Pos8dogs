#define AppName      "MBSport Racing Dogs"
#define AppVersion   "1.0.0"
#define AppPublisher "MBSport"
#define AppExeName   "pos.exe"
; Cada variante se compila por separado (ver build_both.bat) y se copia a su
; propia carpeta en dist\ antes de correr este instalador.
#define ReleaseDirTrifecta  "..\dist\trifecta"
#define ReleaseDirExacta    "..\dist\exacta"
#define IconFile     "..\windows\runner\resources\app_icon.ico"

[Setup]
AppId={{A3B2C1D0-BEEF-4321-ABCD-POS6DOGS2026}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
DefaultDirName={sd}\POS6Dogs
DefaultGroupName={#AppName}
AllowNoIcons=no
OutputDir=.
OutputBaseFilename=MBSport_Racing_Dogs_Setup
SetupIconFile={#IconFile}
UninstallDisplayIcon={app}\{#AppExeName}
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"

[Types]
; Exactamente dos tipos (sin "custom") => el asistente muestra una pantalla
; de selección con estas dos opciones, mutuamente excluyentes.
Name: "trifecta"; Description: "Version completa (Ganador + Exacta + Tripleta)"
Name: "exacta";   Description: "Version Exacta (Ganador + Exacta, sin Tripleta)"

[Components]
Name: "main"; Description: "Aplicacion POS"; Types: trifecta exacta; Flags: fixed

[Tasks]
Name: "desktopicon"; Description: "Crear icono en el escritorio"; GroupDescription: "Iconos adicionales:"; Flags: checkedonce

[Files]
; ── Variante TRIFECTA ────────────────────────────────────────────────────
Source: "{#ReleaseDirTrifecta}\{#AppExeName}"; DestDir: "{app}"; Flags: ignoreversion; Components: main; Check: IsTrifecta
Source: "{#ReleaseDirTrifecta}\flutter_windows.dll";         DestDir: "{app}"; Flags: ignoreversion; Components: main; Check: IsTrifecta
Source: "{#ReleaseDirTrifecta}\screen_retriever_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion; Components: main; Check: IsTrifecta
Source: "{#ReleaseDirTrifecta}\window_manager_plugin.dll";   DestDir: "{app}"; Flags: ignoreversion; Components: main; Check: IsTrifecta
Source: "{#ReleaseDirTrifecta}\printing_plugin.dll";         DestDir: "{app}"; Flags: ignoreversion; Components: main; Check: IsTrifecta
Source: "{#ReleaseDirTrifecta}\pdfium.dll";                  DestDir: "{app}"; Flags: ignoreversion; Components: main; Check: IsTrifecta
Source: "{#ReleaseDirTrifecta}\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs; Components: main; Check: IsTrifecta

; ── Variante EXACTA ──────────────────────────────────────────────────────
Source: "{#ReleaseDirExacta}\{#AppExeName}"; DestDir: "{app}"; Flags: ignoreversion; Components: main; Check: IsExacta
Source: "{#ReleaseDirExacta}\flutter_windows.dll";         DestDir: "{app}"; Flags: ignoreversion; Components: main; Check: IsExacta
Source: "{#ReleaseDirExacta}\screen_retriever_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion; Components: main; Check: IsExacta
Source: "{#ReleaseDirExacta}\window_manager_plugin.dll";   DestDir: "{app}"; Flags: ignoreversion; Components: main; Check: IsExacta
Source: "{#ReleaseDirExacta}\printing_plugin.dll";         DestDir: "{app}"; Flags: ignoreversion; Components: main; Check: IsExacta
Source: "{#ReleaseDirExacta}\pdfium.dll";                  DestDir: "{app}"; Flags: ignoreversion; Components: main; Check: IsExacta
Source: "{#ReleaseDirExacta}\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs; Components: main; Check: IsExacta

[Icons]
; Acceso directo en el menú inicio
Name: "{group}\{#AppName}";          Filename: "{app}\{#AppExeName}"; IconFilename: "{app}\{#AppExeName}"
Name: "{group}\Desinstalar {#AppName}"; Filename: "{uninstallexe}"

; Acceso directo en el escritorio (solo si la tarea "desktopicon" fue seleccionada)
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; IconFilename: "{app}\{#AppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExeName}"; Description: "Iniciar {#AppName}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"

[Code]
function IsTrifecta: Boolean;
begin
  Result := WizardSetupType(False) = 'trifecta';
end;

function IsExacta: Boolean;
begin
  Result := WizardSetupType(False) = 'exacta';
end;
