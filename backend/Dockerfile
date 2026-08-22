# syntax=docker/dockerfile:1

# ================================
# Stage 1: Build
# ================================
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copy project files first for better layer caching
COPY Opalsnz.Accounting.Api/Opalsnz.Accounting.Api.csproj Opalsnz.Accounting.Api/
COPY Opalsnz.Accounting.Model/Opalsnz.Accounting.Model.csproj Opalsnz.Accounting.Model/
COPY Opalsnz.Accounting.Service/Opalsnz.Accounting.Service.csproj Opalsnz.Accounting.Service/
COPY Opalsnz.Accounting.Db/Opalsnz.Accounting.Db.csproj Opalsnz.Accounting.Db/

RUN dotnet restore Opalsnz.Accounting.Api/Opalsnz.Accounting.Api.csproj

# Copy the rest of the source and publish
COPY Opalsnz.Accounting.Api/ Opalsnz.Accounting.Api/
COPY Opalsnz.Accounting.Model/ Opalsnz.Accounting.Model/
COPY Opalsnz.Accounting.Service/ Opalsnz.Accounting.Service/
COPY Opalsnz.Accounting.Db/ Opalsnz.Accounting.Db/

WORKDIR /src/Opalsnz.Accounting.Api
RUN dotnet publish Opalsnz.Accounting.Api.csproj -c Release -o /app/publish /p:UseAppHost=false

# ================================
# Stage 2: Runtime
# ================================
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

COPY --from=build /app/publish .

RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=20s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

ENTRYPOINT ["dotnet", "Opalsnz.Accounting.Api.dll"]
