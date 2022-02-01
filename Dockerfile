# escape=`

FROM mcr.microsoft.com/dotnet/framework/sdk:4.8 as builder

WORKDIR c:\HelloWorldFramework
# COPY HelloWorldNetFramework.sln .
COPY HelloWorldNetFramework\HelloWorldNetFramework.csproj .\HelloWorldNetFramework\
# COPY HelloWorldNetFramework.Tests\HelloWorldNetFramework.Tests.csproj .\HelloWorldNetFramework.Tests\
RUN dotnet restore  HelloWorldNetFramework.csproj

COPY HelloWorldNetFramework c:\HelloWorldFramework

COPY . .
WORKDIR c:\HelloWorldFramework\
RUN dotnet build HelloWorldNetFramework.csproj /p:OutputPath=c:\out /p:Configuration=Release

# app image
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8
SHELL [ "powershell", "-Command", "$ErrorActionPreference = 'Stop';" ]

ENV APP_ROOT=C:\web-app

WORKDIR ${APP_ROOT}
RUN New-WebApplication -Name 'app' -Site 'Default Web Site' -PhysicalPath $env:APP_ROOT

COPY  --from=builder C:\out\_PublishedWebsites\HelloWorldFramework ${APP_ROOT}

