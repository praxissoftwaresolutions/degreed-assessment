# Build stage using the .NET SDK
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj and restore dependencies
COPY ["BackendApi.csproj", "."]
RUN dotnet restore

# Copy remaining source code and build
COPY . .
WORKDIR "/src/BackendApi"
RUN dotnet build "BackendApi.csproj" -c Release -o /app/build

# Publish the application
RUN dotnet publish "BackendApi.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage using the ASP.NET Core Runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=build /app/publish .

# Default ASP.NET Core port is 8080 starting with .NET 8
EXPOSE 8080
ENTRYPOINT ["dotnet", "BackendApi.dll"]