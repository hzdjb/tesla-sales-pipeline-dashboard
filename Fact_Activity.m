// Power Query (M) for table: Fact_Activity
// Paste into: Home > Transform data > New Source > Blank Query > Advanced Editor, then rename the query to "Fact_Activity".
// Depends on the text parameter "DataFolder" (see DataFolder.m).
let
    Source = Csv.Document(
        File.Contents(DataFolder & "Fact_Activity.csv"),
        [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
    ),
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    // Schema contract: keep only the columns the model uses; fail loudly if one is missing
    SelectedColumns = Table.SelectColumns(PromotedHeaders, {"ActivityId", "ActivityDate", "SalesRepId", "StoreId", "LeadId", "OpportunityId", "ActivityType", "Outcome", "IsConnected", "IsPositive", "NextActionDays"}, MissingField.Error),
    // Empty CSV cells become null before typing, so optional fields never raise type errors
    BlankToNull = Table.TransformColumns(SelectedColumns, {}, each if _ = "" then null else _),
    ChangedTypes = Table.TransformColumnTypes(
        BlankToNull,
        {
            {"ActivityId", type text},
            {"ActivityDate", type date},
            {"SalesRepId", type text},
            {"StoreId", type text},
            {"LeadId", type text},
            {"OpportunityId", type text},
            {"ActivityType", type text},
            {"Outcome", type text},
            {"IsConnected", type logical},
            {"IsPositive", type logical},
            {"NextActionDays", Int64.Type}
        },
        "en-NZ"
    )
in
    ChangedTypes
