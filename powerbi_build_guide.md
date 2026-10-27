# Power BI build guide (30-60 minutes)

Target: Power BI Desktop (Windows), a 2025 or later release with **DAX query view** and **TMDL view**.
Reference picture of the finished report: `docs/index.html` (the live GitHub Pages dashboard).

## 0. Before you start
1. `pip install -r requirements.txt` then `python generate_data.py` - expect `22/22 checks passed`.
2. `python tools/validate_model.py` - expect `ALL CHECKS PASSED`. It writes `docs/model_validation_report.md`
   with the exact numbers each visual should show; use it to check your build.
3. Power BI Desktop > File > Options and settings > Options > **Current file > Data Load**:
   untick **Autodetect new relationships after data is loaded**. Autodetect would add
   `Dim_SalesRep[StoreId] -> Dim_Store`, which creates 7 ambiguous filter paths (see validation report, section B).

## 1. New file
File > Save as `tesla_dashboard.pbix` (gitignored).

## 2. Load the 14 tables (Power Query)
1. Home > Transform data. Home > Manage Parameters > New: Name `DataFolder`, Type Text,
   Current value = full path of your `output` folder **ending with a backslash**, e.g. `C:\Projects\tesla-sales-pipeline-dashboard\output\`.
2. For each file in `powerquery/` (except DataFolder.m): New Source > Blank Query > Advanced Editor >
   paste the file > Done > rename the query to the file name (e.g. `Lead`).
3. Check each query shows no error rows (View > Column quality). The M already types every column
   and turns blank cells into null, so there should be none.
4. Close & Apply. Row counts should match the `Row counts` block printed by generate_data.py.

`powerbi/connection.pbids` opens a Folder connection instead; it is a shortcut for browsing the files,
not the recommended path, because a Folder source combines files into one table.

## 3. Relationships
Option A (fast): View > **TMDL view** > New script > paste `dax/relationships.tmdl` > Apply.
Option B (manual): Model view, drag each pair below. All are many-to-one, single direction.

| From (many) | To (one) | Active |
|---|---|---|
| Lead[CreatedDate] | Dim_Date[Date] | Yes |
| Lead[StoreId] / [SalesRepId] / [SourceId] / [ModelId] | Dim_Store / Dim_SalesRep / Dim_Source / Dim_Model | Yes |
| Opportunity[CreatedDate] | Dim_Date[Date] | Yes |
| Opportunity[CloseDate] | Dim_Date[Date] | **No** (used by USERELATIONSHIP for revenue) |
| Opportunity[StoreId] / [SalesRepId] / [SourceId] / [ModelId] / [AccountId] | matching dimension | Yes |
| Fact_LeadConversion[ConversionDate] / [StoreId] / [SalesRepId] / [SourceId] | Dim_Date / Dim_Store / Dim_SalesRep / Dim_Source | Yes |
| Fact_Activity[ActivityDate] / [StoreId] / [SalesRepId] | Dim_Date / Dim_Store / Dim_SalesRep | Yes |
| Dim_Target[TargetMonth] / [StoreId] | Dim_Date / Dim_Store | Yes |
| Vehicle / Charging / TradeIn [OpportunityId] | Opportunity[OpportunityId] | Yes |

Deliberately **not** related: Fact_LeadConversion and Fact_Activity to Lead/Opportunity, Vehicle/Charging/TradeIn to
Dim_Date or Dim_Model, Dim_SalesRep to Dim_Store. Each of these would create a second filter path.

Hide technical columns (right-click > Hide in report view): all `*Id` columns on fact tables, Vehicle[ModelId],
Dim_Date[MonthStart].

## 4. Date table
Select Dim_Date > Table tools > Mark as date table > column `Date`.

## 5. Calculated columns
Paste each column from `dax/calculated_columns.dax` with Table tools > New column (11 columns).
Then: Dim_Date[YearMonth] and [MonthYear] > Sort by column > MonthYearSort; Opportunity[Stage] > Sort by column > StageOrder.

## 6. Measures
Option A (fast, keeps formats and folders): TMDL view > New script > paste `dax/measures.tmdl` > Apply.
Option B: DAX query view > paste `dax/measures.dax` > Run > click **Update model with changes**; then set
format strings from the comment above each measure.
Check: DAX query view result for `Total Leads` = 19,765 and `Lead SLA 24h %` = 84.1% (with no filters it shows the full data).

## 7. Report-level filter
Filters pane > Filters on all pages > add Dim_Date[IsReportingWindow] = True.
Without it, Oct-Dec 2026 targets enter the denominators (Leads Target 23,931 instead of 20,714).

## 8. Theme
View > Themes > Browse for themes > `theme/dashboard_theme.json`.

## 9-10. Pages
Canvas 1280 x 720, 12-column grid, 16 px margins. Positions are (column start-end, row) on that grid;
row 1 = top band. Every page gets a slicer row: Dim_Date[YearMonth] (between), Dim_Store[StoreName] (dropdown).

### Page 1 - Executive Summary
| Visual | Fields / measures | Position | Purpose |
|---|---|---|---|
| 6 cards | Total Leads (+Leads vs Target %), Lead to Opp %, Close Won %, Deliveries (+Deliveries vs Target %), Total Revenue NZD (+Revenue vs Target %), Pipeline Coverage % | cols 1-12, row 1 (2 cols each) | Headline health |
| Clustered column + line | X Dim_Date[YearMonth]; columns Total Revenue NZD; line Revenue Target | cols 1-8, rows 2-3 | Revenue vs target by delivery month |
| Table "SLA status" | rows: 4 SLAs (use a field parameter or 4 small cards); values actual, target, SLA Alert; conditional colour = Alert Colour measures | cols 9-12, rows 2-3 | Which SLA is off track |
| Clustered column + line | X YearMonth; Total Leads; line Leads Target | cols 1-12, row 4 | Lead volume trend |

### Page 2 - Funnel & SLA
| Visual | Fields / measures | Position | Purpose |
|---|---|---|---|
| 4 cards | Lead SLA 24h %, TD SLA 48h %, FollowUp SLA 7d %, LTP SLA 30d %; subtitle = SLA Alert; callout colour = Alert Colour | row 1, 3 cols each | SLA at a glance |
| Funnel | Total Leads, Total Opportunities, Closed Won (use a field parameter or a stage table) | cols 1-5, rows 2-3 | Where volume drops |
| Line chart | X YearMonth; Lead SLA 24h %, TD SLA 48h %, FollowUp SLA 7d %; constant lines at targets | cols 6-12, rows 2-3 | SLA trend |
| Table | Dim_Source[SourceName], SourceCategory, Total Leads, Lead to Opp %, Close Won %, Lead SLA 24h % (data bars on Lead to Opp %) | cols 1-12, row 4 | Source quality |

### Page 3 - Store/Rep & Public Pool
| Visual | Fields / measures | Position | Purpose |
|---|---|---|---|
| 4 cards | Public Pool Leads, Public Pool Reactivation %, Pool Leads Converted, Stale LTP | row 1 | Pool health |
| Matrix | Rows Dim_Store[StoreName]; Total Leads, Deliveries, Revenue vs Target %, 4 SLA % with background colour = SLA Alert Colour | cols 1-8, rows 2-3 | Store scorecard |
| Bar chart | Dim_Store[StoreName]; Public Pool Leads; tooltip page (step 12) | cols 9-12, rows 2-3 | Pool by store |
| Table | Dim_SalesRep[RepName], TenureMonths, Total Leads, 3 SLA %, Close Won %, Deliveries, Total Revenue NZD | cols 1-12, row 4 | Advisor coaching list |

Note: unclaimed pool leads have a blank SalesRepId and appear as (Blank) in the rep table. Keep the row and rename it in the
visual, or add a visual filter RepName is not blank.

### Page 4 - SLA Detail & Loss
| Visual | Fields / measures | Position | Purpose |
|---|---|---|---|
| Bar chart | Lead[ResponseBand]; Total Leads | cols 1-6, row 1-2 | Where 24h misses sit |
| Matrix | Dim_SalesRep[TenureBand]; Lead SLA 24h %, TD SLA 48h %, FollowUp SLA 7d % | cols 7-12, rows 1-2 | Tenure vs SLA (coaching case) |
| Bar chart | Opportunity[DeclineReason]; Closed Lost | cols 1-4, row 3 | Loss reasons |
| Bar chart | Opportunity[IsFollowUpSLA7dMet]; Closed Lost | cols 5-8, row 3 | Lost deals vs follow-up timing |
| Bar chart | Opportunity[DelayReason]; Total Opportunities (filter DelayReason not blank) | cols 9-12, row 3 | Delivery delay reasons |
| Bar chart | Opportunity[Stage] (filter IsClosed = False); Weighted Pipeline, tooltip Open Opportunities | cols 1-12, row 4 | Open pipeline by stage |

## 11. Drill-through: Store detail
New page "Store Detail", Page information > Drill through > add Dim_Store[StoreName]. Add cards (Total Leads,
Deliveries, Total Revenue NZD, SLA Alert), the monthly revenue column chart and the rep table. Right-click a store
in any visual > Drill through > Store Detail.

## 12. Tooltip page: Store bar chart
New page "Store Tooltip", Page information > Allow use as tooltip; canvas Tooltip size. Add cards Public Pool Lead %,
Public Pool Reactivation %, Lead SLA 24h %, LTP SLA 30d %. On page 3's bar chart: Format > Tooltips > Type Report page >
Store Tooltip.

## 13. Before you share
- [ ] Numbers on each page match `docs/model_validation_report.md` (report window, no slicers)
- [ ] No (Blank) rows in store/date visuals; the rep (Blank) row is labelled
- [ ] Report-level filter IsReportingWindow = True is on
- [ ] Revenue visuals use Total Revenue NZD (delivery date), not ExpectedRevenue
- [ ] Every page title, axis and card has a readable label in the dark theme
- [ ] Footer text: "Simulated data. Not affiliated with or using data from Tesla, Inc."
- [ ] Screenshots exported to `docs/img/` for the README
