#!/usr/bin/env python3
"""Menyiapkan gambar untuk dokumen akhir.

Dua tugas:
1. Menggambar diagram HTML (arsitektur, DFD, ERD) menjadi PNG, lalu menyimpan
   salinan SVG-nya di folder yang sama.
2. Mengubah catatan gambar pada markdown menjadi embed gambar, sehingga
   diagram benar-benar ikut masuk ke dokumen.

Pemakaian:
    python3 figures_to_images.py --render          # gambar diagram HTML menjadi PNG
    python3 figures_to_images.py --embed           # catatan gambar -> embed gambar
    python3 figures_to_images.py --render --embed
"""
import argparse
import os
import re
import shutil
import subprocess
import sys
import urllib.parse

REPO = "/Users/allvvnt/alfianSpace/Kampus/PA-Management-kost"
MODULES = os.path.join(REPO, "PA/docs/modules")
WORK = os.path.join(REPO, "PA/docs/System design")

BROWSERS = [
    "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge",
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    "/Applications/Chromium.app/Contents/MacOS/Chromium",
]

# ---------------------------------------------------------------------------
# 1. Diagram HTML -> PNG
# ---------------------------------------------------------------------------
HTML_DIAGRAMS = [
    "01-Gambaran-umum/01_arsitektur_keseluruhan/arsitektur_terpadu.html",
    "01-Gambaran-umum/02_arsitektur_backend/arsitektur_backend_modulith.html",
    "03-DFD/dfd_level_0_context.html",
    "03-DFD/dfd_level_1_dekomposisi.html",
    "04-ERD/erd_sistem_dinamis.html",
    "04-ERD/diagram_klasifikasi_modul.html",
    "07-Evaluasi/flowchart_evaluasi.html",
    "08-design-lama/erd_sistem_lama.html",
]


def browser():
    for b in BROWSERS:
        if os.path.exists(b):
            return b
    return None


def dump_dom(browser_path, url):
    out = subprocess.run(
        [browser_path, "--headless=new", "--disable-gpu", "--no-sandbox",
         f"--user-data-dir=/tmp/figure-render-profile", "--dump-dom", url],
        capture_output=True, text=True, timeout=180)
    return out.stdout


def largest_svg(dom):
    """Ambil elemen SVG terbesar dari DOM (bukan ikon tombol)."""
    dom = re.sub(r"<script\b.*?</script>", " ", dom, flags=re.S)
    dom = re.sub(r"<style\b.*?</style>", " ", dom, flags=re.S)
    dom = re.sub(r"<!--.*?-->", " ", dom, flags=re.S)
    cands = []
    pos = 0
    while True:
        start = dom.find("<svg", pos)
        if start == -1:
            break
        depth, i = 1, start + 4
        end = -1
        while i < len(dom):
            nxt_open = dom.find("<svg", i)
            nxt_close = dom.find("</svg>", i)
            if nxt_close == -1:
                break
            if nxt_open != -1 and nxt_open < nxt_close:
                depth += 1
                i = nxt_open + 4
                continue
            depth -= 1
            i = nxt_close + 6
            if depth == 0:
                end = i
                break
        if end == -1:
            pos = start + 4
            continue
        chunk = dom[start:end]
        w, h = svg_size(chunk)
        cands.append((w * h, chunk))
        pos = end
    if not cands:
        return None
    cands.sort(key=lambda x: x[0])
    return cands[-1][1]


def svg_size(svg_text, default=(1400, 1000)):
    tag = re.search(r"<svg\b[^>]*>", svg_text, re.S)
    if not tag:
        return default
    w = re.search(r'\bwidth="([0-9.]+)', tag.group(0))
    h = re.search(r'\bheight="([0-9.]+)', tag.group(0))
    try:
        return (int(float(w.group(1))), int(float(h.group(1))))
    except Exception:
        return default


def render_svg(svg_path, png_path, width=None, height=None, scale=1):
    b = browser()
    if not b:
        return False
    url = "file://" + urllib.parse.quote(svg_path)
    win_w = int((width or 1400) * scale)
    win_h = int((height or 1000) * scale)
    subprocess.run(
        [b, "--headless=new", "--disable-gpu", "--no-sandbox", "--hide-scrollbars",
         f"--user-data-dir=/tmp/figure-render-profile",
         "--default-background-color=FFFFFF",
         f"--window-size={win_w},{win_h}", f"--screenshot={png_path}", url],
        capture_output=True, timeout=180)
    return os.path.exists(png_path)


def render_html_diagrams():
    b = browser()
    if not b:
        print("  ! peramban headless tidak ditemukan, diagram HTML dilewati")
        return
    for rel in HTML_DIAGRAMS:
        src = os.path.join(WORK, rel)
        if not os.path.exists(src):
            print(f"  ! tidak ditemukan: {rel}")
            continue
        dom = dump_dom(b, "file://" + urllib.parse.quote(src))
        svg = largest_svg(dom)
        if not svg:
            print(f"  ! SVG tidak terbaca: {rel}")
            continue
        svg_path = os.path.splitext(src)[0] + ".svg"
        # serialisasi HTML membuang xmlns, padahal berkas SVG dibaca sebagai XML
        if "xmlns=" not in svg[:400]:
            svg = svg.replace("<svg", '<svg xmlns="http://www.w3.org/2000/svg"', 1)
        with open(svg_path, "w", encoding="utf-8") as f:
            f.write('<?xml version="1.0" encoding="UTF-8"?>\n' + svg)
        png_path = os.path.splitext(src)[0] + ".png"
        sw, sh = svg_size(svg)
        if render_svg(svg_path, png_path, sw, sh):
            print(f"  OK  {os.path.relpath(png_path, REPO)}")
        else:
            print(f"  ! gagal merender: {rel}")


# ---------------------------------------------------------------------------
# 2. Diagram Mermaid -> PNG
# ---------------------------------------------------------------------------
def render_mermaid():
    if shutil.which("mmdc") is None:
        print("  ! mermaid-cli (mmdc) tidak terpasang, diagram Mermaid dilewati")
        return
    env = dict(os.environ)
    for b in BROWSERS:
        if os.path.exists(b):
            env["PUPPETEER_EXECUTABLE_PATH"] = b
            break
    root = os.path.join(WORK, "02-BPMN")
    for dirpath, _dirs, files in os.walk(root):
        for f in sorted(files):
            if not f.endswith(".mmd"):
                continue
            src = os.path.join(dirpath, f)
            stem = os.path.splitext(src)[0]
            if os.path.exists(stem + ".html") or os.path.exists(stem + ".svg"):
                continue
            png = stem + ".png"
            subprocess.run(["mmdc", "-i", src, "-o", png, "-b", "white", "-s", "3"],
                           env=env, capture_output=True, timeout=300)
            print(f"  {'OK ' if os.path.exists(png) else '!  '}{os.path.relpath(png, REPO)}")


# ---------------------------------------------------------------------------
# 3. Catatan gambar -> embed gambar
# ---------------------------------------------------------------------------
NOTE = re.compile(
    r"^> \*\*Gambar (?P<no>[\d.]+) — (?P<title>.+?):\*\* `(?P<path>[^`]+)`.*$")


def image_for(path):
    """PNG yang dipakai untuk embed: file .mmd/.html menghasilkan PNG,
    folder mencari PNG atau berkas diagram di dalamnya."""
    p = os.path.join(REPO, path)
    if os.path.isdir(p):
        for name in sorted(os.listdir(p)):
            if name.lower().endswith(".png"):
                return os.path.join(p, name)
            if name.lower().endswith(".mmd"):
                cand = os.path.splitext(os.path.join(p, name))[0] + ".png"
                if os.path.exists(cand):
                    return cand
        return None
    if p.lower().endswith((".mmd", ".html", ".svg")):
        cand = os.path.splitext(p)[0] + ".png"
        return cand if os.path.exists(cand) else None
    return p if os.path.exists(p) else None


def embed(md_text):
    out = []
    for line in md_text.split("\n"):
        m = NOTE.match(line.strip())
        if m:
            png = image_for(m.group("path"))
            if png:
                rel = os.path.relpath(png, MODULES)
                out.append(f"![Gambar {m.group('no')} — {m.group('title').strip()}]"
                           f"({rel}){{width=15cm}}")
                continue
        out.append(line)
    return "\n".join(out)


def convert_file(path, out_path=None, base=None):
    """Ubah catatan gambar pada markdown menjadi embed gambar."""
    base = base or os.path.dirname(os.path.abspath(path))
    text = open(path, encoding="utf-8").read()
    out, changed = [], 0
    for line in text.split("\n"):
        m = NOTE.match(line.strip())
        if m:
            png = image_for(m.group("path"))
            if png:
                rel = os.path.relpath(png, base).replace(" ", "%20")
                out.append(f"![Gambar {m.group('no')} — {m.group('title').strip()}]"
                           f"({rel}){{width=15cm}}")
                changed += 1
                continue
        out.append(line)
    dest = out_path or path
    with open(dest, "w", encoding="utf-8") as f:
        f.write("\n".join(out))
    print(f"  {changed} catatan gambar diubah menjadi embed gambar -> {dest}")
    return changed


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--render", action="store_true", help="gambar diagram menjadi PNG")
    ap.add_argument("--convert", metavar="BERKAS", help="ubah catatan gambar pada berkas markdown")
    ap.add_argument("--output", help="berkas keluaran untuk --convert")
    args = ap.parse_args()
    if not (args.render or args.convert):
        args.render = True
    if args.render:
        print("Merender diagram Mermaid:")
        render_mermaid()
        print("Merender diagram HTML:")
        render_html_diagrams()
    if args.convert:
        print("Mengubah catatan gambar menjadi embed gambar:")
        convert_file(args.convert, args.output)
    return 0


if __name__ == "__main__":
    sys.exit(main())
