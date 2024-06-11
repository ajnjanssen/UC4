# Stage 1: Build the application
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

# Set the working directory inside the container
WORKDIR /src

# Copy the .csproj file and restore dependencies
COPY ["src/Api/Api.csproj", "src/Api/"]
RUN dotnet restore "src/Api/Api.csproj"

# Copy the entire project and build it
COPY . .
RUN dotnet publish "src/Api/Api.csproj" -c Release -o /app/publish --no-restore

# Stage 2: Create the runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime

# Set the working directory inside the container
WORKDIR /app

# Copy the published files from the build stage
COPY --from=build /app/publish .

# Set environment variables
ENV ASPNETCORE_URLS=http://+:3000
ENV NIXPACKS_CSHARP_SDK_VERSION=8.0

# Expose the port that the application runs on
EXPOSE 3000

# Entry point to run the application
ENTRYPOINT ["dotnet", "Api.dll"]
