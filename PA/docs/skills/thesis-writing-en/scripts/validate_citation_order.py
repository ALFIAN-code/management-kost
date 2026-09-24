#!/usr/bin/env python3
"""Validate sequential numeric citation order in Markdown chapters.

Example:
  python validate_citation_order.py chapters \
    --references chapters/references.md \
    --order chapter-1 chapter-2 chapter-3 chapter-4 chapter-5
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

CITATION_RE = re.compile(r"\[((?:\d{1,3})(?:\s*[-,，、]\s*\d{1,3})*)\]")


def iter_citation_numbers(text: str):
    """Yield numbers from [1], [1][2], [1,2], [1、2] and [1-3]."""
    for match in CITATION_RE.finditer(text):
        token = match.group(1)
        parts = re.split(r"\s*[,，、]\s*", token)
        for part in parts:
            if not part:
                continue
            range_match = re.fullmatch(r"(\d{1,3})\s*-\s*(\d{1,3})", part)
            if range_match:
                start, end = map(int, range_match.groups())
                step = 1 if start <= end else -1
                yield from range(start, end + step, step)
            else:
                yield int(part)


def first_seen_citations(chapters_dir: Path, order: list[str]) -> list[int]:
    seen: set[int] = set()
    first_seen: list[int] = []
    for name in order:
        path = chapters_dir / f"{name}.md"
        if not path.exists():
            print(f"WARN missing chapter: {path}", file=sys.stderr)
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        for number in iter_citation_numbers(text):
            if number not in seen:
                seen.add(number)
                first_seen.append(number)
    return first_seen


def reference_numbers(path: Path) -> list[int]:
    if not path.exists():
        return []
    text = path.read_text(encoding="utf-8", errors="replace")
    return [int(n) for n in re.findall(r"^\s*\[(\d{1,3})\]", text, flags=re.MULTILINE)]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("chapters", type=Path, help="Directory containing chapter Markdown files")
    parser.add_argument("--references", type=Path, help="Markdown reference list file")
    parser.add_argument(
        "--order",
        nargs="+",
        default=["chapter-1", "chapter-2", "chapter-3", "chapter-4", "chapter-5", "chapter-6", "chapter-7"],
        help="Chapter basename order without .md",
    )
    args = parser.parse_args()

    first_seen = first_seen_citations(args.chapters, args.order)
    expected = list(range(1, len(first_seen) + 1))
    ok = True

    print(f"First-seen citations: {first_seen}")
    if first_seen != expected:
        print(f"ERROR citation order must be {expected}, got {first_seen}", file=sys.stderr)
        ok = False

    if args.references:
        refs = reference_numbers(args.references)
        print(f"Reference entries: {refs}")
        if refs != expected:
            print(f"ERROR reference list must match {expected}, got {refs}", file=sys.stderr)
            ok = False

    if ok:
        print("OK citation order is sequential.")
        return 0
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
