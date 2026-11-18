#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "Usage: $0 OUTPUT_DIRECTORY [GIT_REF]" >&2
    exit 2
fi

spec=openid-connect-claims-aggregation-1_0
revision=$(git rev-parse --verify --end-of-options "${2:-HEAD}^{commit}")
build_dir=$(mktemp -d)
trap 'rm -rf "$build_dir"' EXIT
mkdir "$build_dir/cache"

# Render the committed file so the displayed revision always matches the input.
git show "$revision:$spec.md" > "$build_dir/$spec.md"
mmark "$build_dir/$spec.md" > "$build_dir/$spec.xml"
xml2rfc --html --no-network --cache "$build_dir/cache" \
    -o "$build_dir/$spec.html" "$build_dir/$spec.xml"

cat > "$build_dir/index.html" <<EOF
<!doctype html>
<html lang="en">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>OpenID Connect Claims Aggregation — WG Review Preview</title>
<main>
  <h1>OpenID Connect Claims Aggregation</h1>
  <p>Editor’s Draft — WG Review Preview</p>
  <p>Source commit
    <a href="https://github.com/openid/claims-aggregation/commit/$revision"><code>$revision</code></a>
  </p>
  <ul>
    <li><a href="$spec.html">Read the Editor’s Draft (HTML)</a></li>
    <li><a href="$spec.xml">Download the generated XML</a></li>
    <li><a href="https://openid.net/specs/$spec.html">Published WG Draft</a></li>
  </ul>
</main>
</html>
EOF

mkdir -p "$1"
cp "$build_dir/index.html" "$build_dir/$spec.xml" "$build_dir/$spec.html" "$1/"
