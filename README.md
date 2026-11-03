# <img src="https://raw.githubusercontent.com/SpamTagger/st-mailscanner/refs/heads/main/st-mailscanner.svg" alt="st-mailscanner logo" style="height:2em; vertical-align:middle;"> st-mailscanner

## Usage

This project provides custom versions of [MailScanner](https://github.com/MailScanner/v5) for SpamTagger. Ordinary SpamTagger users will have no need to interact with this project. Official releases of the `st-mailscanner` package will be provided automatically for the official SpamTagger VM images using the `bootc` update mechanism. The remaining information on this page is relevant to developers and those who wish to modify the Exim build in an unsupported environment.

The `st-mailscanner` package is built from the official MailScanner source tree by applying a set of patches that MailCleaner accumulated over the years. This requires the version to be provided as a commandline option, as described below, which matches an existing Git tag.

The official release of the `st-mailscanner` package is built using GitHub Actions any time that a new tagged version is created matching `v*`. The number following `v` will be used as the target version to check out and build. Once built for each supported OS version the GitHub Action will create a signed SHA256SUM file to verify the legitimacy and integrity of the packages and then create a new GitHub release. Finally, this will trigger the [`debs`](https://github.com/SpamTagger/debs) to fetch the packages and update the repository at `debs.spamtagger.org`. The latest available package in this repository will be built in to SpamTagger-Bootc images.

### One-step build

To build the package on your own, you can execute the build script which will build the package using `podman`:

```
./build_and_extract.sh 5.3.3-2
```

`5.3.3-2` represents the Exim version you would like to build, as provided by the `5.3.3-2` tag from the [official repository](https://github.com/MailScanner/v5). You can optionally provide the distribution codename as the second argument, and an alternate export destination directory as the third. By default, it will use:

```
./build-and-export.sh 5.3.3-2 trixie ./dist
```

and the output file will be located at `./dist/st-mailscanner_5.3.3-2+trixie_all.deb`.

### Manual build

The `Containerfile` serves as documentation for the step-by-step building of the package.

## Developer notes

There are several significant patches which need to be applied to MailScanner to provide our expected functionality. This repository hosts only the patches and applies them to the matching MailScanner tag. When MailScanner creates new releases, we need to ensure that the patches still function appropriately. The [MailScanner-v5](https://github.com/SpamTagger/MailScanner-v5) repo exists to rebase and generate diffs from upstream to be replicated here.

Note: To maintain compatibility with `st-exim` we will still use a `v` prefix for our release tags, however MailScanner does not include this prefix, unlike Exim.
Also Note: MailScanner is a pure Perl project and so the package is not architecture specific. The only architecture target is 'all'.

The [`debs`](/SpamTagger/debs) repository gets triggered to rebuild the APT repository every time that a new package is built. In GitHub actions, any existing package revisions for this version will be discovered and the next available suffix will autoatically be added. This is a hack around only being able to have one release for each Git Tag. It allows us to delete the release and tag, then push a new tag for the same version to rebuild and get a new package version. The old package version remains in the APT repo but will no longer be available in Releases.

Specific version dependencies are defined in the `DEBIAN/control` file for the [`spamtagger`](/SpamTagger/SpamTagger) package to ensure that versions remain compatible. We then build [bootc images](/SpamTagger/SpamTagger-Bootc) which define a specific version of that package in order to produce `current` and `stable` images.

TODO: There is not currently a supported option to create a patched version of the same release. Unlike `st-exim` where we can apply our own package version suffix, MailScanner already does this, so if we need to provide a patched version of the same upstream version, we would need to use the `5.3.3-2+patch1` format.
