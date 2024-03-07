# Publish a new release

1. Edit `Chart.yaml` and set expected semver version
2. `git commit -m chore(release): publish vX.Y.Z"`
3. `make changelog`
4. `git diff`
5. `git commit --amend traefikee/Chart.yaml traefikee/Changelog.md`

