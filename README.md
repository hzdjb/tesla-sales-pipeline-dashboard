# EV Sales Pipeline Dashboard (Tesla-style retail, simulated)

**▶ Live dashboard: https://hzdjb.github.io/tesla-sales-pipeline-dashboard/**  
4 interactive pages (hover tooltips, sortable advisor table, store filter). Works on desktop and phone, no login.

A Power BI portfolio project that models the sales pipeline of an EV direct-sales network in New Zealand:
lead capture, first response, test drive, follow-up, order and delivery. A Python script generates
two years of realistic, rule-based CRM data (14 tables, ~125k rows); a validation script simulates the
Power BI model and DAX outside Power BI; Power Query, DAX and a theme turn it into a 4-page report.
The scenario draws on the author's experience running a Tesla experience centre in Beijing.
**All data is simulated. This project is not affiliated with Tesla, Inc. and uses no Tesla data.**

## Business problem
Store managers know their monthly deliveries but not where the pipeline leaks. The questions this report answers:
1. Are we on track for leads, deliveries and revenue against each store's targets?
2. Which of the four service SLAs (first response 24h, test drive booked 48h, follow-up 7 days, long-term prospect
   contact 30 days) is off track, in which store, and for which advisors?
3. How many leads go cold and land in the public pool, and how much does the pool recover?
4. Why are deals lost or deliveries delayed, and is there enough pipeline for next quarter?

## Dashboard pages
| Page | What it shows |
|---|---|
| Executive Summary | Leads, conversion, deliveries, revenue vs target, pipeline coverage, SLA status |
| Funnel & SLA | Funnel, four SLA cards with red/amber/green alerts, SLA trend, lead source quality |
| Store/Rep & Public Pool | Store scorecard against store targets, public pool KPIs, advisor table |
| SLA Detail & Loss | Response-time bands, tenure vs SLA, loss reasons, follow-up timing of lost deals, delay reasons, open pipeline |

The live dashboard (`docs/index.html`) is built from the same numbers the Power BI model produces.

![Executive Summary](docs/img/page1_executive.png)
*Executive Summary (live dashboard; swap for Power BI screenshots once built)*
![Funnel & SLA](docs/img/page2_funnel_sla.png)
*Funnel & SLA*
![Store/Rep & Public Pool](docs/img/page3_store_rep_pool.png)
*Store, rep and public pool*
![SLA Detail & Loss](docs/img/page4_sla_loss.png)
*SLA detail and loss analysis*

## Data model
Star schema with two fact families. All relationships many-to-one, single direction.

```
Dim_Date ──< Lead >── Dim_Store, Dim_SalesRep, Dim_Source, Dim_Model
Dim_Date ──< Opportunity >── Dim_Store, Dim_SalesRep, Dim_Source, Dim_Model, Account
Dim_Date ┄┄< Opportunity[CloseDate]          (inactive, used for revenue by delivery date)
Opportunity ──< Vehicle, Charging, TradeIn
Dim_Date ──< Fact_LeadConversion >── Dim_Store, Dim_SalesRep, Dim_Source
Dim_Date ──< Fact_Activity >── Dim_Store, Dim_SalesRep
Dim_Date ──< Dim_Target >── Dim_Store
```
Design choices worth discussing:
- Lead and Opportunity are both facts. Fact_LeadConversion holds the link as an event, so there is exactly one
  filter path between any two tables (checked automatically).
- Revenue is dated by delivery through `USERELATIONSHIP` on an inactive relationship, while pipeline counts use creation date.
- Targets are one long table (store x month x metric), so adding a KPI adds rows, not columns.

## How to run
```bash
pip install -r requirements.txt        # Python 3.10-3.13
python generate_data.py                # 14 CSVs in output/, samples in data/sample/, 22 quality checks
python tools/validate_model.py         # simulates the Power BI model; writes docs/model_validation_report.md
python tools/build_dashboard.py        # rebuilds docs/index.html, the GitHub Pages dashboard
```
Then follow [docs/powerbi_build_guide.md](docs/powerbi_build_guide.md) (30-60 minutes).

## Repository
| Path | Content |
|---|---|
| `generate_data.py` | Seeded (42) generator with business rules and quality checks |
| `tools/validate_model.py` | Type, relationship, DAX-reference and measure simulation |
| `powerquery/*.m` | One query per table plus the `DataFolder` parameter |
| `dax/measures.tmdl`, `dax/measures.dax` | 66 measures (TMDL script with formats and folders; DAX query version) |
| `dax/relationships.tmdl` | 24 relationships as a TMDL script |
| `dax/calculated_columns.dax` | 11 calculated columns |
| `theme/dashboard_theme.json` | Dark theme, red accent, Segoe UI |
| `docs/` | Live dashboard (`index.html`), business rules, data dictionary, build guide, validation report |
| `tools/build_dashboard.py` | Builds the GitHub Pages dashboard from the validated measures |

Docs: [business rules](docs/business_rules.md) · [data dictionary](docs/data_dictionary.md) · [validation report](docs/model_validation_report.md)

## Known limitations
- Simulated data: distributions are tuned to look plausible, not fitted to any real dealer network.
- Simplified CRM: no quotes, finance applications, cases or multi-currency; one opportunity per lead.
- The LTP SLA is a snapshot measure (as at 2026-09-30), so its monthly trend is not meaningful.
- Vehicle prices are illustrative, not current NZ list prices.
- `data/sample/` holds the first 500 rows of each table for preview; foreign keys are not complete within the sample.

## Tech stack
Python (pandas, NumPy, Faker) · Power BI Desktop · Power Query (M) · DAX · TMDL

## License
MIT - see [LICENSE](LICENSE).
