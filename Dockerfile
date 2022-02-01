# escape=`

FROM mcr.microsoft.com/windows/servercore:ltsc2019 as builder

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'SilentlyContinue'; $ProgressPreference = 'SilentlyContinue';"]


WORKDIR c:\HelloWorldFramework
COPY HelloWorldNetFramework\HelloWorldNetFramework.csproj .\HelloWorldNetFramework\

## Install .Net 3.5
RUN Invoke-WebRequest -Outfile microsoft-windows-netfx3.zip `
    -Uri https://dotnetbinaries.blob.core.windows.net/dockerassets/microsoft-windows-netfx3-1809.zip
RUN tar -zxf microsoft-windows-netfx3.zip
RUN Remove-Item -Force microsoft-windows-netfx3.zip
##Install the package
RUN DISM /Online /Quiet /Add-Package /PackagePath:.\microsoft-windows-netfx3-ondemand-package~31bf3856ad364e35~amd64~~.cab
#clean up
RUN del microsoft-windows-netfx3-ondemand-package~31bf3856ad364e35~amd64~~.cab
RUN Remove-Item -Force -Recurse ${Env:TEMP}\*
RUN Invoke-WebRequest -Outfile C:\ServiceMonitor.exe `
    -Uri https://dotnetbinaries.blob.core.windows.net/servicemonitor/2.0.1.6/ServiceMonitor.exe
RUN c:\Windows\System32\inetsrv\appcmd.exe set app /app.name:"Default Web Site/" 
RUN c:\Windows\System32\inetsrv\appcmd set apppool  /apppool.name:DefaultAppPool /managedRuntimeVersion:"v2.0"
#Install IIS
RUN Add-WindowsFeature Web-Server
RUN Add-WindowsFeature Web-Asp-Net
RUN New-WebAppPool myAppServerAppPool
#RUN New-WebApplication -Name HelloWorldFrameworkServer -Site 'Default Web Site' -PhysicalPath C:\HelloWorldFramework\VDir -ApplicationPool HelloWorldFrameworkServerAppPool; 

RUN Remove-Item -Recurse C:\inetpub\wwwroot\*


# WORKDIR c:\HelloWorldFramework
# COPY HelloWorldNetFramework.sln .
# COPY HelloWorldNetFramework\HelloWorldNetFramework.csproj .\HelloWorldNetFramework\
# COPY HelloWorldNetFramework.Tests\HelloWorldNetFramework.Tests.csproj .\HelloWorldNetFramework.Tests\
RUN dotnet restore  HelloWorldNetFramework\HelloWorldNetFramework.csproj --verbosity detailed

COPY HelloWorldNetFramework c:\HelloWorldFramework

COPY . .
WORKDIR c:\HelloWorldFramework\
RUN dotnet build HelloWorldNetFramework\HelloWorldNetFramework.csproj /p:OutputPath=c:\out /p:Configuration=Release

# app image
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8
SHELL [ "powershell", "-Command", "$ErrorActionPreference = 'Stop';" ]

ENV APP_ROOT=c:\web-app

WORKDIR ${APP_ROOT}
RUN New-WebApplication -Name 'app' -Site 'Default Web Site' -PhysicalPath $env:APP_ROOT

COPY  --from=builder C:\out\_PublishedWebsites\HelloWorldFramework ${APP_ROOT}

