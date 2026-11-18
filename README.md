# OpenID Connect Claims Aggregation 1.0

This repository tracks the OpenID Connect Claims Aggregation specification, a
work item of the [AB/Connect Working Group](https://openid.net/wg/connect/).
The specification defines how an OpenID Provider obtains claims from Claims
Providers and returns them to a Relying Party as aggregated claims.

## Specification

- [Published draft](https://openid.net/specs/openid-connect-claims-aggregation-1_0.html)
- [Editor's Draft (WG review preview)](https://openid.github.io/claims-aggregation/)
- [Editor's draft source](openid-connect-claims-aggregation-1_0.md)

### Build the Editor's Draft locally

Install [Mmark 2.2.48](https://github.com/mmarkdown/mmark/releases/tag/v2.2.48)
for your platform and put `mmark` on PATH. From the repository root, install
`xml2rfc` in a virtual environment and install Mermaid CLI using npm.
GitHub Actions uses Python 3.12 and the Chrome installed on the runner.

```sh
preview_dir=$(mktemp -d)
python3 -m venv "$preview_dir/venv"
. "$preview_dir/venv/bin/activate"
python -m pip install xml2rfc==3.31.0
PUPPETEER_SKIP_DOWNLOAD=true npm install --prefix "$preview_dir/mermaid" \
  --ignore-scripts --no-audit --no-fund @mermaid-js/mermaid-cli@11.12.0
export PATH="$preview_dir/mermaid/node_modules/.bin:$PATH"
# Set this to the Chrome or Chromium executable on your system.
export PUPPETEER_EXECUTABLE_PATH="/path/to/chrome"
bash scripts/build-editor-draft.sh "$preview_dir/site"
```

Open `$preview_dir/site/index.html` for the review landing page, the generated
HTML and XML, and the source commit link. The script builds the committed
Markdown at `HEAD` by default. Pass a commit or branch name as the second
argument to reproduce a particular revision, such as `origin/master`.
The generated HTML embeds the rendered Mermaid figures as SVG images. The
generated XML retains the Mermaid source for editing.

### Publish the WG review preview

Select **GitHub Actions** as the source in **Settings → Pages**. When a
revision is ready for WG review, open **Actions → Editor's Draft preview**,
select **Run workflow**, and choose `master`. The preview displays the
`master` commit used for that run.

The published WG Draft follows the
[OpenID Foundation publication process](https://openid.net/wg/resources/publishing-specifications/).

## Contributing

See the [contribution guidelines](CONTRIBUTING.md) before submitting an
[issue](https://github.com/openid/claims-aggregation/issues) or pull request.

## License

See the [Notices section of the specification](openid-connect-claims-aggregation-1_0.md#notices)
for the copyright and license terms.
