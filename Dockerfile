# ---------- BUILD STAGE ----------
# Use .NET 8 SDK (align with current VedAstro target; adjust if needed)
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy only project files first for better layer caching
COPY API/API.csproj API/
COPY Library/Library.csproj Library/

# Restore
RUN dotnet restore API/API.csproj

# Copy the rest of the repo
COPY . .

# Publish API
RUN dotnet publish API/API.csproj -c Release -o /app/publish

# ---------- RUNTIME STAGE ----------
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# Render Free injects PORT (often 10000). Bind Kestrel to $PORT.
ENV ASPNETCORE_URLS=http://0.0.0.0:${PORT}

# OPTIONAL: if your API needs TZ data, locales, etc, install here

COPY --from=build /app/publish .
# Expose 8080 for local runs; Render will still pass $PORT
EXPOSE 8080

ENTRYPOINT ["dotnet", "API.dll"]
