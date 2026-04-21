# Build stage using the .NET SDK
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copy csproj and restore dependencies
COPY ["FrontendWeb.csproj", "."]
RUN dotnet restore

# Copy remaining source code and build
COPY . .
WORKDIR "/src/FrontendWeb"
RUN dotnet build "FrontendWeb.csproj" -c Release -o /app/build

# Publish the application
RUN dotnet publish "FrontendWeb.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage using the ASP.NET Core Runtime
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
COPY --from=build /app/publish .

# Default ASP.NET Core port is 8080 starting with .NET 10
EXPOSE 8080
ENTRYPOINT ["dotnet", "FrontendWeb.dll"]