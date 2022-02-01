# escape=`

FROM mcr.microsoft.com/windows/servercore:ltsc2019 as builder

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

WORKDIR c:\HelloWorldFramework
# COPY HelloWorldNetFramework.sln .
COPY HelloWorldNetFramework\HelloWorldNetFramework.csproj .\HelloWorldNetFramework\
# COPY HelloWorldNetFramework.Tests\HelloWorldNetFramework.Tests.csproj .\HelloWorldNetFramework.Tests\
RUN dotnet restore  HelloWorldNetFramework\HelloWorldNetFramework.csproj

COPY HelloWorldNetFramework c:\HelloWorldFramework

COPY . .
WORKDIR c:\HelloWorldFramework\
RUN dotnet build HelloWorldNetFramework\HelloWorldNetFramework.csproj /p:OutputPath=c:\out /p:Configuration=Release

# app image
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8
SHELL [ "powershell", "-Command", "$ErrorActionPreference = 'Stop';" ]

ENV APP_ROOT=C:\web-app

WORKDIR ${APP_ROOT}
RUN New-WebApplication -Name 'app' -Site 'Default Web Site' -PhysicalPath $env:APP_ROOT

COPY  --from=builder C:\out\_PublishedWebsites\HelloWorldFramework ${APP_ROOT}

