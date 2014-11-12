; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "Exporty"
#define MyAppVersion "1.0"
#define MyAppPublisher "Schneider Electric"
#define MyAppURL "http://www.multisight.com"
#define MyAppExeName "Exporty.exe"

[Code]
//  Code pasted from the following address, for examples and more visit it:
//  http://www.vincenzo.net/isxkb/index.php?title=Service_-_Functions_to_Start%2C_Stop%2C_Install%2C_Remove_a_Service


// function IsServiceInstalled(ServiceName: string) : boolean;
// function IsServiceRunning(ServiceName: string) : boolean;
// function InstallService(FileName, ServiceName, DisplayName, Description : string;ServiceType,StartType :cardinal) : boolean;
// function RemoveService(ServiceName: string) : boolean;
// function StartService(ServiceName: string) : boolean;
// function StopService(ServiceName: string) : boolean;
// function SetupService(service, port, comment: string) : boolean;

type
    SERVICE_STATUS = record
        dwServiceType               : cardinal;
        dwCurrentState              : cardinal;
        dwControlsAccepted          : cardinal;
        dwWin32ExitCode             : cardinal;
        dwServiceSpecificExitCode   : cardinal;
        dwCheckPoint                : cardinal;
        dwWaitHint                  : cardinal;
    end;
    HANDLE = cardinal;

const
    SERVICE_QUERY_CONFIG        = $1;
    SERVICE_CHANGE_CONFIG       = $2;
    SERVICE_QUERY_STATUS        = $4;
    SERVICE_START               = $10;
    SERVICE_STOP                = $20;
    SERVICE_ALL_ACCESS          = $f01ff;
    SC_MANAGER_ALL_ACCESS       = $f003f;
    SERVICE_WIN32_OWN_PROCESS   = $10;
    SERVICE_WIN32_SHARE_PROCESS = $20;
    SERVICE_WIN32               = $30;
    SERVICE_INTERACTIVE_PROCESS = $100;
    SERVICE_BOOT_START          = $0;
    SERVICE_SYSTEM_START        = $1;
    SERVICE_AUTO_START          = $2;
    SERVICE_DEMAND_START        = $3;
    SERVICE_DISABLED            = $4;
    SERVICE_DELETE              = $10000;
    SERVICE_CONTROL_STOP        = $1;
    SERVICE_CONTROL_PAUSE       = $2;
    SERVICE_CONTROL_CONTINUE    = $3;
    SERVICE_CONTROL_INTERROGATE = $4;
    SERVICE_STOPPED             = $1;
    SERVICE_START_PENDING       = $2;
    SERVICE_STOP_PENDING        = $3;
    SERVICE_RUNNING             = $4;
    SERVICE_CONTINUE_PENDING    = $5;
    SERVICE_PAUSE_PENDING       = $6;
    SERVICE_PAUSED              = $7;

// #######################################################################################
// nt based service utilities
// #######################################################################################
function OpenSCManager(lpMachineName, lpDatabaseName: string; dwDesiredAccess :cardinal): HANDLE;
external 'OpenSCManagerA@advapi32.dll stdcall';

function OpenService(hSCManager :HANDLE;lpServiceName: string; dwDesiredAccess :cardinal): HANDLE;
external 'OpenServiceA@advapi32.dll stdcall';

function CloseServiceHandle(hSCObject :HANDLE): boolean;
external 'CloseServiceHandle@advapi32.dll stdcall';

function CreateService(hSCManager :HANDLE;lpServiceName, lpDisplayName: string;dwDesiredAccess,dwServiceType,dwStartType,dwErrorControl: cardinal;lpBinaryPathName,lpLoadOrderGroup: String; lpdwTagId : cardinal;lpDependencies,lpServiceStartName,lpPassword :string): cardinal;
external 'CreateServiceA@advapi32.dll stdcall';

function DeleteService(hService :HANDLE): boolean;
external 'DeleteService@advapi32.dll stdcall';

function StartNTService(hService :HANDLE;dwNumServiceArgs : cardinal;lpServiceArgVectors : cardinal) : boolean;
external 'StartServiceA@advapi32.dll stdcall';

function ControlService(hService :HANDLE; dwControl :cardinal;var ServiceStatus :SERVICE_STATUS) : boolean;
external 'ControlService@advapi32.dll stdcall';

function QueryServiceStatus(hService :HANDLE;var ServiceStatus :SERVICE_STATUS) : boolean;
external 'QueryServiceStatus@advapi32.dll stdcall';

function QueryServiceStatusEx(hService :HANDLE;ServiceStatus :SERVICE_STATUS) : boolean;
external 'QueryServiceStatus@advapi32.dll stdcall';

function GetLastError() : cardinal;
external 'GetLastError@kernel32.dll stdcall';

function OpenServiceManager() : HANDLE;
begin
    if UsingWinNT() = true then begin
        Result := OpenSCManager('','',SC_MANAGER_ALL_ACCESS);
        if Result = 0 then
            MsgBox('the servicemanager is not available', mbError, MB_OK)
    end
    else begin
            MsgBox('only nt based systems support services', mbError, MB_OK)
            Result := 0;
    end
end;

function IsServiceInstalled(ServiceName: string) : boolean;
var
    hSCM    : HANDLE;
    hService: HANDLE;
begin
    hSCM := OpenServiceManager();
    Result := false;
    if hSCM <> 0 then begin
        hService := OpenService(hSCM,ServiceName,SERVICE_QUERY_CONFIG);
        if hService <> 0 then begin
            Result := true;
            CloseServiceHandle(hService)
        end;
        CloseServiceHandle(hSCM)
    end
end;

function InstallService(FileName, ServiceName, DisplayName, Description : string;ServiceType,StartType :cardinal) : boolean;
var
    hSCM    : HANDLE;
    hService: HANDLE;
begin
    hSCM := OpenServiceManager();
    Result := false;
    if hSCM <> 0 then begin
        hService := CreateService(hSCM,ServiceName,DisplayName,SERVICE_ALL_ACCESS,ServiceType,StartType,0,FileName,'',0,'','','');
        if hService <> 0 then begin
            Result := true;
            // Win2K & WinXP supports aditional description text for services
            if Description<> '' then
                RegWriteStringValue(HKLM,'System\CurrentControlSet\Services\' + ServiceName,'Description',Description);
            CloseServiceHandle(hService)
        end;
        CloseServiceHandle(hSCM)
    end
end;

function RemoveService(ServiceName: string) : boolean;
var
    hSCM    : HANDLE;
    hService: HANDLE;
begin
    hSCM := OpenServiceManager();
    Result := false;
    if hSCM <> 0 then begin
        hService := OpenService(hSCM,ServiceName,SERVICE_DELETE);
        if hService <> 0 then begin
            Result := DeleteService(hService);
            CloseServiceHandle(hService)
        end;
        CloseServiceHandle(hSCM)
    end
end;

function StartService(ServiceName: string) : boolean;
var
    hSCM    : HANDLE;
    hService: HANDLE;
begin
    hSCM := OpenServiceManager();
    Result := false;
    if hSCM <> 0 then begin
        hService := OpenService(hSCM,ServiceName,SERVICE_START);
        if hService <> 0 then begin
            Result := StartNTService(hService,0,0);
            CloseServiceHandle(hService)
        end;
        CloseServiceHandle(hSCM)
    end;
end;

function StopService(ServiceName: string) : boolean;
var
    hSCM    : HANDLE;
    hService: HANDLE;
    Status  : SERVICE_STATUS;
begin
    hSCM := OpenServiceManager();
    Result := false;
    if hSCM <> 0 then begin
        hService := OpenService(hSCM,ServiceName,SERVICE_STOP);
        if hService <> 0 then begin
            Result := ControlService(hService,SERVICE_CONTROL_STOP,Status);
            CloseServiceHandle(hService)
        end;
        CloseServiceHandle(hSCM)
    end;
end;

function IsServiceRunning(ServiceName: string) : boolean;
var
    hSCM    : HANDLE;
    hService: HANDLE;
    Status  : SERVICE_STATUS;
begin
    hSCM := OpenServiceManager();
    Result := false;
    if hSCM <> 0 then begin
        hService := OpenService(hSCM,ServiceName,SERVICE_QUERY_STATUS);
        if hService <> 0 then begin
            if QueryServiceStatus(hService,Status) then begin
                Result :=(Status.dwCurrentState = SERVICE_RUNNING)
            end;
            CloseServiceHandle(hService)
            end;
        CloseServiceHandle(hSCM)
    end
end;

// This function is run at the beginning of uninstallation. This function will stop
// the service if it is running and then sleep for 10 seconds (to allow it time to shutdown).
function InitializeUninstall() : boolean;
var
    running : boolean;
    name    : string;
    tries   : integer;
begin
    name := 'Exporty Service';
    running := IsServiceRunning( name );
    if running = true then
    begin
        StopService( name );
        tries := 6;
        while running = true and (tries > 0) do
        begin
            Sleep( 5000 );
            running := IsServiceRunning( name );
            tries := tries - 1;
        end;
    end;
    Result := true;
end;

// This function is called repeatedly as we progress through installation. If the current state is
// ssDone (happens right before installation is complete) we start the service.
procedure CurStepChanged(CurStep: TSetupStep);
var
    name : string;
begin
    name := 'Exporty Service';
    if CurStep = ssDone then
    begin
        //StartService( name ); I am commenting this out because our users might want a chance to 
        // configure exporty before starting it!
    end;
end;

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{8A1165C9-8EAF-4E6A-8988-CD70656D23A9}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\{#MyAppName}
DefaultGroupName={#MyAppName}
InfoAfterFile=README.TXT
OutputDir=.
OutputBaseFilename=Exporty Setup
SetupIconFile=Exporty.ico
Compression=lzma
SolidCompression=yes

[Files]
Source: "build\Release\Exporty.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "config\config.xml"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\devel_artifacts\lib\avcodec-56.dll"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\devel_artifacts\lib\avdevice-56.dll"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\devel_artifacts\lib\avfilter-5.dll"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\devel_artifacts\lib\avformat-56.dll"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\devel_artifacts\lib\avutil-54.dll"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\devel_artifacts\lib\postproc-53.dll"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\devel_artifacts\lib\swresample-1.dll"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\devel_artifacts\lib\swscale-3.dll"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\devel_artifacts\lib\xsdk.dll"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\devel_artifacts\lib\webby.dll"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\devel_artifacts\lib\avkit.dll"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\devel_artifacts\lib\FrameStoreClient.dll"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\devel_artifacts\lib\MediaParser.dll"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Registry]
Root: HKLM64; Subkey: "Software\Schneider Electric\Exporty\Settings"; ValueType: string; ValueName: "InstallPath"; ValueData: "{app}"

[Run]
Filename: {app}\Exporty.exe; Parameters: "--install" ; Flags: runhidden runascurrentuser

[UninstallRun]
Filename: {app}\Exporty.exe; Parameters: "--uninstall" ; Flags: runhidden runascurrentuser
