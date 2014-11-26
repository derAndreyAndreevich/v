#include <windows.h> 
#include <stdio.h> 

#define SLEEP_TIME 5000 
#define LOGFILE "C:\\service.txt"

int WriteLog(char *str) {
  FILE *log;
  log = fopen(LOGFILE, "a+");

  if (log == NULL) {
    return -1;
  }

  fprintf(log, "%s\n", str);
  fclose(log);

  return 0;
}

SERVICE_STATIS ServiceStatus;
SERVICE_STATIS_HANDLE hStatus;

void ServiceMain(int args, char** argv);
void ControlHandler(DWORD request);
int InitService();

void main() {
  SERVICE_TABLE_ENTRY ServiceTable[2];
  ServiceTable[0].lpServiceName = "MemoryStatus";
  ServiceTable[0].lpServiceProc = (LPSERVICE_MAIN_FUNCTION)ServiceMain;
  ServiceTable[1].lpServiceName = NULL;
  ServiceTable[1].lpServiceProc = NULL;
  StartServiceCtrlDispatcher(ServiceTable);
}

void ServiceMain(int argc, char** argv) { 
   int error; 
 
   ServiceStatus.dwServiceType = SERVICE_WIN32; 
   ServiceStatus.dwCurrentState = SERVICE_START_PENDING; 
   ServiceStatus.dwControlsAccepted = SERVICE_ACCEPT_STOP | SERVICE_ACCEPT_SHUTDOWN;
   ServiceStatus.dwWin32ExitCode = 0; 
   ServiceStatus.dwServiceSpecificExitCode = 0; 
   ServiceStatus.dwCheckPoint = 0; 
   ServiceStatus.dwWaitHint = 0; 
 
   hStatus = RegisterServiceCtrlHandler("MemoryStatus", (LPHANDLER_FUNCTION)ControlHandler); 
   if (hStatus == (SERVICE_STATUS_HANDLE)0) { 
      // Registering Control Handler failed
      return; 
   }  
   // Initialize Service 
   error = InitService(); 

   if (error) {
      // Initialization failed
      ServiceStatus.dwCurrentState = 
         SERVICE_STOPPED; 
      ServiceStatus.dwWin32ExitCode = -1; 
      SetServiceStatus(hStatus, &ServiceStatus); 
      return; 
   } 
   // We report the running status to SCM. 
   ServiceStatus.dwCurrentState = 
      SERVICE_RUNNING; 
   SetServiceStatus (hStatus, &ServiceStatus);
 
   MEMORYSTATUS memory;
   // The worker loop of a service
   while (ServiceStatus.dwCurrentState == 
          SERVICE_RUNNING)
   {
      char buffer[16];
      GlobalMemoryStatus(&memory);
      sprintf(buffer, "%d", memory.dwAvailPhys);
      int result = WriteToLog(buffer);
      if (result)
      {
         ServiceStatus.dwCurrentState = 
            SERVICE_STOPPED; 
         ServiceStatus.dwWin32ExitCode      = -1; 
         SetServiceStatus(hStatus, 
                          &ServiceStatus);
         return;
      }
      Sleep(SLEEP_TIME);
   }
   return; 
}

void ControlHandler(DWORD request) 
{ 
   switch(request) 
   { 
      case SERVICE_CONTROL_STOP: 
         WriteToLog("Monitoring stopped.");

         ServiceStatus.dwWin32ExitCode = 0; 
         ServiceStatus.dwCurrentState = SERVICE_STOPPED; 
         SetServiceStatus (hStatus, &ServiceStatus);
         return; 
 
      case SERVICE_CONTROL_SHUTDOWN: 
         WriteToLog("Monitoring stopped.");

         ServiceStatus.dwWin32ExitCode = 0; 
         ServiceStatus.dwCurrentState = SERVICE_STOPPED; 
         SetServiceStatus (hStatus, &ServiceStatus);
         return; 
        
      default:
         break;
    } 
 
    // Report current status
    SetServiceStatus (hStatus, &ServiceStatus);
 
    return; 
}

