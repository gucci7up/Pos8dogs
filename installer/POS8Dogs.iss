#define AppName      "MBSport DS8 Racing Dog"
#define AppVersion   "1.0.0"
#define AppPublisher "MBSport"
#define AppExeName   "pos.exe"
; DS8 tiene una sola variante: GANADOR + EXACTA. No hay tripleta que elegir,
; asi que a diferencia del instalador de 6 perros no hay pantalla de tipos.
#define ReleaseDir   "dist"
#define IconFile     "..\windows\runner\resources\app_icon.ico"

[Setup]
AppId={{D5E4C3B2-BEEF-4321-ABCD-POS8DOGS2026}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
DefaultDirName={sd}\POS8Dogs
DefaultGroupName={#AppName}
AllowNoIcons=no
OutputDir=.
OutputBaseFilename=MBSport_DS8_Setup
SetupIconFile={#IconFile}
UninstallDisplayIcon={app}\{#AppExeName}
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"

[Tasks]
Name: "desktopicon"; Description: "Crear icono en el escritorio"; GroupDescription: "Iconos adicionales:"; Flags: checkedonce

[Files]
Source: "{#ReleaseDir}\{#AppExeName}";                DestDir: "{app}"; Flags: ignoreversion
Source: "{#ReleaseDir}\flutter_windows.dll";          DestDir: "{app}"; Flags: ignoreversion
Source: "{#ReleaseDir}\screen_retriever_plugin.dll";  DestDir: "{app}"; Flags: ignoreversion
Source: "{#ReleaseDir}\window_manager_plugin.dll";    DestDir: "{app}"; Flags: ignoreversion
Source: "{#ReleaseDir}\printing_plugin.dll";          DestDir: "{app}"; Flags: ignoreversion
Source: "{#ReleaseDir}\pdfium.dll";                   DestDir: "{app}"; Flags: ignoreversion
Source: "{#ReleaseDir}\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#AppName}";             Filename: "{app}\{#AppExeName}"; IconFilename: "{app}\{#AppExeName}"
Name: "{group}\Desinstalar {#AppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#AppName}";       Filename: "{app}\{#AppExeName}"; IconFilename: "{app}\{#AppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExeName}"; Description: "Iniciar {#AppName}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
