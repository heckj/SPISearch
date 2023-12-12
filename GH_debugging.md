# Debugging the (*^*(%^@ GH Actions failures

1. Use tart

The images on Github Actions runners have a version of Xcode that you can't install on Sonoma, because... reason. So it's off to the world of VMs.

    brew install cirruslabs/cli/tart
    tart pull tart pull ghcr.io/cirruslabs/macos-ventura-xcode:14.3.1
    tart clone ghcr.io/cirruslabs/macos-ventura-xcode:14.3.1 macos-ventura-xcode
    tart run --dir=project:~/src/SPISearch macos-ventura-xcode

The project is available at `/Volumes/My Shared Files/project` inside the Guest OS (MacOS 13 Ventura in this case)

Note: this will consume at least 52GB of disk space - the raw image alone is ~43.4 GB compressed. The disk space consumed of the stock image on disk (`~/.tart`):

```
 96G cache
 52G vms
```

More details available on using Tart at https://tart.run/quick-start/

[GH macos-12 image details](https://github.com/actions/virtual-environments/blob/main/images/macos/macos-12-Readme.md)

- Xcode 14.2 default
- Xcode 13.1 -> 14.2 available

[GH macos-13 details](https://github.com/actions/runner-images/blob/main/images/macos/macos-13-Readme.md) [macos-13-arm](https://github.com/actions/runner-images/blob/main/images/macos/macos-13-arm64-Readme.md)

- Xcode 14.3.1 default
- Xcode 15.0.1 available
