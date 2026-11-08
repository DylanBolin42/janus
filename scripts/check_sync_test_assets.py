"""Fail if sync TLS test fixture names or contents enter a production artifact.

Accepts an APK/IPA zip or a built .app directory. Does not print key contents.
"""

import pathlib
import sys
import zipfile

fixtures = pathlib.Path(__file__).resolve().parent.parent / "test/fixtures/sync"
markers = [path.read_bytes() for path in fixtures.glob("*.pem")]
if len(markers) != 2:
    raise SystemExit("Expected the two local TLS test fixtures")


def check(name, data):
    if "test/fixtures/sync" in name or any(marker in data for marker in markers):
        raise SystemExit(f"Test TLS fixture leaked into artifact: {name}")


artifact = pathlib.Path(sys.argv[1])
if artifact.is_dir():
    for path in artifact.rglob("*"):
        if path.is_file():
            check(str(path.relative_to(artifact)), path.read_bytes())
elif artifact.is_file():
    with zipfile.ZipFile(artifact) as archive:
        for entry in archive.infolist():
            if not entry.is_dir():
                check(entry.filename, archive.read(entry))
else:
    raise SystemExit("Build artifact does not exist")
print("Verified: sync TLS test fixtures are absent from the build artifact")
