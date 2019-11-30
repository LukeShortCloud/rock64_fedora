# Change Log

- 0.4.0
    - Allow local builds using rock64_fedora.
    - Enable chronyd (NTP service).
- 0.3.0
    - CentOS releases are now self-building (built on a rock64_fedora CentOS device).
    - Add experimental support for building a Fedora 31 image.
- 0.2.1
    - Missing dependencies for resizing the root partition are now installed.
    - Known issues are now listed in the README file.
- 0.2.0
    - The rock64_fedora.sh script now works.
    - Build from a Debian 10/Buster image instead of 9/Stretch.
    - Use a prebuilt root file system created by `yum` (container images are no longer used).
    - Use a folder in the `$HOME` directory for temporary files (instead of /tmp to handle operating systems that use tmpfs with limited space).
- 0.1.0
    - Start of a proof-of-concept script (not working) to use a CentOS 8 container image combined with a Debian Rock64 baremetal image to create a CentOS 8 baremetal image.
