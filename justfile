# Build the app
build:
    swift build

# Clean build artifacts and cached data
clean:
    swift package clean

# Run the app
run *args:
    swift run windman {{ args }}

# Generate man pages
generate-manual:
    swift package plugin generate-manual
