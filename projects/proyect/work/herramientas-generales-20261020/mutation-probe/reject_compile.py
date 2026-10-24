from pathlib import Path
Path("compile-invoked").write_text("yes")
raise SystemExit(1)
