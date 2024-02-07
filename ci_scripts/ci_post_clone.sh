#!/bin/sh

# Set the -e flag to stop running the script in case a command returns
# a nonzero exit code.
set -e

# allow for any macros needed in the build to be run
defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES
