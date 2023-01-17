# Contribution Guidelines

Thank you for your interest in `sc3me`! When contributing to this repository, please first discuss the change you wish to make via issue. 

The `sc3me` project has a [Code of Conduct](CODE-OF-CONDUCT.md). Please follow it in all your interactions with the project.

Your contributions will also require signoff on commits via the [Developer Certificate of Origin](https://developercertificate.org/) (DCO). When you submit a pull request, a DCO-bot will automatically determine whether you need to provide signoff for your commit. Please follow the instructions provided by DCO-bot, as pull requests cannot be merged until the author(s) have provided signoff to fulfill the DCO requirement.

## Testing

Before submitting PR, make sure the unit tests pass:

```shell
make test
```

And that there are no Go or YAML linting errors:

```shell
make lint
```

## Code reviews

All submissions, including submissions by project members, require review. We
use GitHub pull requests for this purpose. Consult [GitHub Help](https://help.github.com/articles/about-pull-requests/) for more information on using pull requests.

