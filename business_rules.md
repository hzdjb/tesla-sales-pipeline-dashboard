# Business rules

The data simulates an EV direct-sales network in New Zealand: 6 stores, Jan 2025 - Sep 2026, snapshot 2026-09-30.
Each rule says what it is, why it exists, and what breaks without it.

| # | Rule | Why it exists | What breaks without it |
|---|---|---|---|
| 1 | **Lead and Opportunity are decoupled.** About 15% of opportunities have no lead (repeat owners, walk-in orders). | Direct-sales retail creates deals that never pass through marketing. | Lead-to-opportunity rates overstate marketing's contribution; repeat-owner revenue disappears. |
| 2 | **Fact_LeadConversion is the only link** between a Lead and its Opportunity: one row per conversion, a lead converts at most once, ConversionDate = Opportunity CreatedDate. | Mirrors CRM lead convert. Keeps one filter path in the model. | Relating Lead directly to Opportunity creates an ambiguous date path (Dim_Date -> Lead -> Opportunity and Dim_Date -> Opportunity). |
| 3 | **Public pool.** A lead with no contact within 72 hours, or whose advisor leaves, goes to the pool (IsPublicPool = TRUE, owner cleared). About 25% are reclaimed by a colleague (IsReactivated = TRUE, new owner). Opportunities are released when the owner leaves, or when a Long Term Prospect has no contact for 45 days. | Stops leads from going cold under one advisor. | No way to measure leakage or the value recovered by the pool. |
| 4 | **Four SLAs.** Lead: first response <= 24h. TD: test drive booked <= 48h after opportunity creation. Follow-up: <= 7 days after the test drive. LTP: Long Term Prospects contacted within 30 days of the snapshot. A lead never contacted counts as a Lead SLA miss. | These are the controllable steps that drive conversion. | The dashboard shows outcomes only, with nothing a store manager can act on. |
| 5 | **Long Term Prospect is a Stage**, not a status. Stages: Test Drive Scheduled -> Test Drive Completed -> Negotiation -> Order Placed -> Closed Won; or Closed Lost; or Long Term Prospect (open). | Customers not buying this quarter still need nurturing, and the pipeline must show them. | LTP customers look lost, the LTP SLA cannot be measured, and pipeline is understated. |
| 6 | **Probability is fixed by Stage** (10 / 25 / 50 / 80 / 100 / 0 / 5%). WeightedRevenue = ExpectedRevenue x Probability. ExpectedRevenue = model price + options. | Consistent forecasting across advisors. | Advisors set their own probabilities; weighted pipeline becomes opinion. |
| 7 | **Charging and TradeIn requests can happen at any stage**; each row records the stage at that moment. | Customers ask about home charging and trade-ins before deciding. | Attach rates are understated and early-stage buying signals are lost. |
| 8 | **All targets live in Dim_Target**, long format: store x month x metric (Leads, ClosedWon, Revenue, 4 SLA rates). Targets run to Dec 2026; SLA ambition differs by store. | One place to maintain targets; new metrics add rows, not columns. | Hard-coded targets in DAX; no store-specific targets; next-quarter coverage cannot be calculated. |
| 9 | **Closed Lost requires DeclineReason. Delivery more than 30 days after order requires DelayReason.** | Loss and delay analysis needs a reason, not a free-text note. | Page 4 cannot explain why deals are lost or slow. |
| 10 | **Every Closed Won has exactly one Vehicle row**; CloseDate = DeliveryDate. | Revenue is recognised at delivery. | Revenue by month double counts or misses deliveries. |
| 11 | **Account Segment** is Private / Small Business / Fleet. CustomerLifetimeValue = vehicles bought (including pre-2025 for existing owners) + installed charging + an estimated service value. | Fleet and repeat owners behave differently and are worth more. | Every customer is treated the same; repeat business is invisible. |
| 12 | **Fact_Activity** rows link to exactly one Lead or one Opportunity. Outcome sets IsConnected (Positive / Neutral / Negative) and IsPositive. NextActionDays 0-30 (0 after a Negative outcome). | Activity quality, not just volume, explains SLA results. | Connected and positive rates cannot be calculated. |
| 13 | **Advisors only own records inside their employment dates and their own store.** Store Managers own no leads. TenureMonths runs to LeaveDate or the snapshot. | Matches how CRM ownership works. | Records owned by people who had left; rep-level SLA becomes meaningless. |
| 14 | **SLA performance improves with tenure**, plus random variation. | Gives the rep page a real coaching story. | A flat rep table with nothing to discuss. |
| 15 | **Quarter-end delivery push**: some deliveries move into the last month of the quarter. | Typical of EV direct sales. | Revenue trend looks unrealistically smooth. |

## Data integrity rules (enforced by generate_data.py, 22 checks)
1-9 primary keys unique and not null; 10-14 no orphan foreign keys (blank owner allowed only for unclaimed pool records,
and Activity has exactly one of LeadId / OpportunityId); 15 date order (lead <= conversion = opportunity created <= close <= snapshot,
order <= delivery) plus advisor tenure and store consistency; 16 probability matches stage; 17 weighted revenue arithmetic;
18 one vehicle per won deal; 19 decline reason on every loss; 20 activity links to one record; 21 SLA flags match hours/days;
22 Dim_Date covers every date and has no gaps. Any failure exits with code 1.
