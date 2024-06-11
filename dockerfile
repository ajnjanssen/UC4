# Stage 1: Build the application
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

# Set the working directory inside the container
WORKDIR /app

# Copy the .csproj file and restore dependencies
COPY UC4.csproj ./
RUN dotnet restore UC4.csproj

# Copy the entire project and build it
COPY . .
RUN dotnet publish UC4.csproj -c Release -o /app/publish --no-restore

# Stage 2: Create the runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime

# Install curl and SQLite
RUN apt-get update && apt-get install -y curl sqlite3 libsqlite3-dev

# Set the working directory inside the container
WORKDIR /app

# Copy the published files from the build stage
COPY --from=build /app/publish .

# Set environment variables
ENV ASPNETCORE_URLS=http://+:3000
ENV NIXPACKS_CSHARP_SDK_VERSION=8.0

# Expose the port that the application runs on
EXPOSE 3000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=1m --retries=3 CMD curl --fail http://localhost:3000 || exit 1

# Entry point to run the application
ENTRYPOINT ["dotnet", "UC4.dll"]

