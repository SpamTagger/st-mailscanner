# <img src="https://raw.githubusercontent.com/SpamTagger/st-mailscanner/refs/heads/main/st-mailscanner.svg" alt="st-mailscanner logo" style="height:2em; vertical-align:middle;"> st-mailscanner

## Usage

This project provides custom versions of [MailScanner](https://github.com/MailScanner/v5) for SpamTagger. Ordinary SpamTagger users will have no need to interact with this project. Official releases of the `st-mailscanner` package will be provided automatically for the official SpamTagger VM images using the `bootc` update mechanism. The remaining information on this page is relevant to developers and those who wish to modify the Exim build in an unsupported environment.

The `st-mailscanner` package is built from the official MailScanner source tree by applying a set of patches that MailCleaner accumulated over the years. This requires the version to be provided as a commandline option, as described below, which matches an existing Git tag.

The official release of the `st-mailscanner` package is built using GitHub Actions any time that a new tagged version is created matching `v*`. The number following `v` will be used as the target version to check out and build. Once built for each supported OS and architecture version the GitHub Action will create a signed SHA256SUM file to verify the legitimacy and integrity of the packages and then create a new GitHub release. Finally, this will trigger the [`debs`](https://github.com/SpamTagger/debs) to fetch the packages and update the repository at `debs.spamtagger.org`. The latest available package in this repository will be built in to SpamTagger-Bootc images.

### One-step build

To build the package on your own, you can execute the build script which will build the package using `podman`:

```
./build_and_extract.sh 5.3.3-2
```

`5.3.3-2` represents the Exim version you would like to build, as provided by the `5.3.3-2` tag from the [official repository](https://code.exim.org/exim/exim). You can optionally provide the distribution codename as the second argument and the architecture (amd64, arm64) as the third, and an alternate export destination directory as the forth. By default, it will use:

```
./build-and-export.sh 5.3.3-2 trixie amd64 ./dist
```

and the output file will be located at `./dist/st-mailscanner_5.3.3-2+trixie_amd64.deb`.

### Manual build

The `Containerfile` serves as documentation for the step-by-step building of the package.

## Developer notes

There are several significant patches which need to be applied to MailScanner to provide our expected functionality. This repository hosts only the patches and applies them to the matching MailScanner tag. When MailScanner creates new releases, we need to ensure that the patches still function appropriately. The [MailScanner-v5](https://github.com/SpamTagger/MailScanner-v5) repo exists to rebase and generate diffs from upstream to be replicated here.

It is best practice to increment the default version number within `Dockerfile` and this document with each release, however, this is not strictly necessary so long as we correctly tag the new version.

Note: To maintain compatibility with `st-exim` we will still use a `v` prefix for our release tags, however MailScanner does not include this prefix, unlike Exim.

TODO: There is not currently a supported option to create a patched version of the same release (ie. `5.3.3-2+patch1`). An accomadation for this would need to be made within the `build-and-extract.sh` script to appropriately strip the `+patch1` suffix when pulling the MailScanner tag, but leave it on when building the package. Since we generally rely on upstream to fix bugs, it is much more likely that we would just release `5.3.3-2` if/when it becomes available rather than to create a patched version ourselves. Also, since we distribute updates via SpamTagger-Bootc, and the `debs` repo will correctly serve the latest release files when new VM images are being built, this is of little relevance. The consequence is that users will still install a patched version, but it will simply have the same named version as the un-patched version.
