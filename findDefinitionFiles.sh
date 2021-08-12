#!/usr/bin/env bash
set -euo pipefail

findDefinitionFiles() (
    local input="$1"; shift
    local output="$1"; shift
    mkdir -p "$output"

    set -o noglob

    cd "$input"
    find . -iname "go.mod" -exec bash -c "echo '{}' >> '$output/GoMod'" \;
    find . -iname "bower.json" -exec bash -c "echo '{}' >> '$output/Bower'" \;
    find . -iname "Cargo.toml" -exec bash -c "echo '{}' >> '$output/Cargo'" \;
    find . -iname "Gemfile" -exec bash -c "echo '{}' >> '$output/Bundler'" \;
    find . -iname "Podfile" -exec bash -c "echo '{}' >> '$output/CocoaPods'" \;
    find . -iname "Cartfile.resolved" -exec bash -c "echo '{}' >> '$output/Carthage'" \;
    find . \( -iname "build.gradle" -o -iname "build.gradle.kts" -o -iname "settings.gradle" -o -iname "settings.gradle.kts" \) -exec bash -c "echo '{}' >> '$output/Gradle'" \;
    find . -iname "pom.xml" -exec bash -c "echo '{}' >> '$output/Maven'" \;
    find . -iname "package.json" -exec bash -c "echo '{}' >> '$output/Npm'" \;
    find . \( -iname "conanfile.txt" -o -iname "conanfile.py" \) -exec bash -c "echo '{}' >> '$output/Conan'" \;
    find . \( -iname "*requirements*.txt" -o -iname "setup.py" \) -exec bash -c "echo '{}' >> '$output/Pip'" \;
    find . \( -iname "build.sbt" -o -iname "build.scala" \) -exec bash -c "echo '{}' >> '$output/Sbt'" \;
    find . -iname "pubspec.yaml" -exec bash -c "echo '{}' >> '$output/Pub'" \;
    find . -iname "packages.config" -exec bash -c "echo '{}' >> '$output/NuGet'" \;
    find . -iname "Gopkg.toml" -exec bash -c "echo '{}' >> '$output/GoDep'" \;
    find . \( -iname "*.spdx" -o -iname "*.spdx.rdf" -o -iname "*.spdx.yml" -o -iname "*.spdx.yaml" -o -iname "*.spdx.json" \) -exec bash -c "echo '{}' >> '$output/SpdxDocumentFile'" \;
    find . -iname "stack.yaml" -exec bash -c "echo '{}' >> '$output/Stack'" \;
    find . -iname "Pipfile.lock" -exec bash -c "echo '{}' >> '$output/Pipenv'" \;
    find . -iname "composer.json" -exec bash -c "echo '{}' >> '$output/Composer'" \;
    find . \( -iname "*.csproj" -o -iname "*.fsproj" -o -iname "*.vcxproj" \) -exec bash -c "echo '{}' >> '$output/DotNet'" \;
    find . -iname "package.json" -exec bash -c "echo '{}' >> '$output/Yarn'" \;
)

findDefinitionFiles "$1" "$2"
