FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build

WORKDIR /src

COPY src/ ./src/

RUN dotnet restore ./src/dotnet-demoapp.csproj
RUN dotnet publish ./src/dotnet-demoapp.csproj -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:6.0

WORKDIR /app

COPY --from=build /app/publish .

EXPOSE 80

ENTRYPOINT ["dotnet", "dotnet-demoapp.dll"]