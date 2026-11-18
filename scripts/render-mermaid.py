"""Render Mermaid code blocks in the generated HTML as embedded SVG images."""

import base64
from pathlib import Path
import subprocess
import sys
from tempfile import TemporaryDirectory

from lxml import html


def render_diagrams(output):
    document = html.parse(str(output))
    blocks = document.xpath(
        "//div[contains(concat(' ', normalize-space(@class), ' '), ' lang-mermaid ')]"
    )
    if not blocks:
        return

    with TemporaryDirectory() as temporary:
        directory = Path(temporary)
        source = directory / "diagram.mmd"
        svg = directory / "diagram.svg"
        for block in blocks:
            (code,) = block.xpath("./pre")
            source.write_text(code.text_content(), encoding="utf-8")
            subprocess.run(
                ["mmdc", "-i", str(source), "-o", str(svg), "--backgroundColor", "white"],
                check=True,
            )
            image_data = base64.b64encode(svg.read_bytes()).decode("ascii")
            caption = block.xpath("normalize-space(ancestor::figure[1]/figcaption)")
            image = html.Element(
                "img",
                src=f"data:image/svg+xml;base64,{image_data}",
                alt=caption or "Mermaid diagram",
                style="width: 100%; height: auto;",
            )
            block.set("class", "art-svg artwork")
            block.replace(code, image)

    document.write(str(output), encoding="utf-8", method="html")


if __name__ == "__main__":
    render_diagrams(Path(sys.argv[1]))
