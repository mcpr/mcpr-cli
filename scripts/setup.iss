[Setup]

#define VerFile FileOpen("../version.txt")
#define AppVer FileRead(VerFile)
#expr FileClose(VerFile)
#undef VerFile

AppId={{B95FF975-A348-42FE-9399-C4AECFEC80B8}
AppName=MCPR-CLI
AppVersion={#AppVer}
AppPublisher=Filiosoft, LLC
AppPublisherURL=https://mcpr.github.io/mcpr-cli
AppSupportURL=https://mcpr.github.io/mcpr-cli
AppUpdatesURL=https://mcpr.github.io/mcpr-cli
DefaultDirName={pf}\MCPR-CLI
DefaultGroupName=MCPR-CLI
AllowNoIcons=yes
LicenseFile=LICENSE
OutputDir=bin
SourceDir=../
OutputBaseFilename=mcpr-windows-setup
SetupIconFile=art/icon.ico
Compression=lzma
SolidCompression=yes
ChangesEnvironment=true

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: modifypath; Description: Set PATH to MCPR-CLI; Flags: unchecked

[Files]
Source: "bin/windows/mcpr.exe"; DestDir: "{app}"; DestName: "mcpr.exe"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\{cm:UninstallProgram,MCPR CLI}"; Filename: "{uninstallexe}"

[Code]

const 
    ModPathName = 'modifypath'; 
    ModPathType = 'user'; 

function ModPathDir(): TArrayOfString; 
begin 
    setArrayLength(Result, 1) 
    Result[0] := ExpandConstant('{app}'); 
end; 
#include "modpath.iss"
