"""
tools/build_dashboard.py
Builds docs/index.html - the interactive dashboard page served by GitHub Pages.

Run after:  python generate_data.py  and  python tools/validate_model.py
The numbers come from output/dashboard_data.json (written by validate_model.py) and are embedded in the page,
so the published site needs no server, no CSV files and no Power BI licence.
"""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
template = (ROOT / "tools" / "dashboard_template.html").read_text(encoding="utf-8")
data = (ROOT / "output" / "dashboard_data.json").read_text(encoding="utf-8")
body = template.replace("__DATA__", data)
page = (
    "<!doctype html>\n<html lang=\"en\">\n<head>\n<meta charset=\"utf-8\">\n"
    "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1, viewport-fit=cover\">\n"
    "<meta name=\"description\" content=\"Interactive EV sales pipeline dashboard built from simulated NZ retail CRM data.\">\n"
    "<style>body{margin:0}img{max-width:100%}</style>\n</head>\n<body>\n" + body + "\n</body>\n</html>\n"
)
(ROOT / "docs" / "index.html").write_text(page, encoding="utf-8")
print(f"Wrote docs/index.html ({len(page) / 1024:.0f} KB)")
