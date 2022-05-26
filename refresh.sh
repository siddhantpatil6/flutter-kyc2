#!/bin/bash

flutter pub upgrade

git stash -- ./.android/build.gradle ./.android/app/build.gradle ./.android/app/src/main/AndroidManifest.xml