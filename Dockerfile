#Depending on the operating system of the host machines(s) that will build or run the containers, the image specified in the FROM statement may need to be changed.
#For more information, please see https://aka.ms/containercompat 

# escape=`

FROM mcr.microsoft.com/dotnet/framework/sdk:4.8 as builder

WORKDIR c:\\HelloWorldFramework
COPY HelloWorldNetFramework.sln .
COPY HelloWorldNetFramework\\HelloWorldNetFramework.csproj .\\HelloWorldNetFramework
COPY HelloWorldNetFramework.Tests\\HelloWorldNetFramework.csproj .\\HelloWorldNetFramework.Tests

RUN nuget restore HelloWorldNetFramework.sln

COPY HelloWorldNetFramework c:\\HelloWorldFramework
RUN msbuild HelloWorldNetFramework.csproj /p:OutputPath=c:\out /p:Configuration=Release

# app image
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8
SHELL [ "powershell", "-Command", "$ErrorActionPreference = 'Stop';" ]

ENV APP_ROOT=C:\web-app

WORKDIR ${APP_ROOT}
RUN New-WebApplication -Name 'app' -Site 'Default Web Site' -PhysicalPath $env:APP_ROOT

COPY  --from=builder C:\out\_PublishedWebsites\HelloWorldFramework ${APP_ROOT}

