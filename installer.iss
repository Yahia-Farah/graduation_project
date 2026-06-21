[Setup]
AppId={{8A8C3B12-A12B-4E3D-9F8C-1234567890AB}
AppName=El-Mostashar
AppVersion=1.0.0
AppPublisher=com.example
DefaultDirName={autopf}\El-Mostashar
DefaultGroupName=El-Mostashar
DisableProgramGroupPage=yes
OutputDir=installers
OutputBaseFilename=El-Mostashar-Installer
Compression=lzma
SolidCompression=yes
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "build\windows\x64\runner\Release\el_mostashar.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\El-Mostashar"; Filename: "{app}\el_mostashar.exe"
Name: "{autodesktop}\El-Mostashar"; Filename: "{app}\el_mostashar.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\el_mostashar.exe"; Description: "{cm:LaunchProgram,El-Mostashar}"; Flags: nowait postinstall skipifsilent
