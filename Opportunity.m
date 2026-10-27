// Power Query (M) for table: Opportunity
// Paste into: Home > Transform data > New Source > Blank Query > Advanced Editor, then rename the query to "Opportunity".
// Depends on the text parameter "DataFolder" (see DataFolder.m).
let
    Source = Csv.Document(
        File.Contents(DataFolder & "Opportunity.csv"),
        [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
    ),
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    // Schema contract: keep only the columns the model uses; fail loudly if one is missing
    SelectedColumns = Table.SelectColumns(PromotedHeaders, {"OpportunityId", "AccountId", "StoreId", "SalesRepId", "SourceId", "ModelId", "CreatedDate", "Stage", "StageEnteredDate", "CloseDate", "IsClosed", "IsWon", "ExpectedRevenue", "Probability", "WeightedRevenue", "TDScheduledHours", "IsTDSLA48hMet", "FollowUpDays", "IsFollowUpSLA7dMet", "LastContactDate", "IsLTPSLA30dMet", "IsPublicPool", "IsReactivated", "PublicPoolDate", "DelayReason", "DeclineReason"}, MissingField.Error),
    // Empty CSV cells become null before typing, so optional fields never raise type errors
    BlankToNull = Table.TransformColumns(SelectedColumns, {}, each if _ = "" then null else _),
    ChangedTypes = Table.TransformColumnTypes(
        BlankToNull,
        {
            {"OpportunityId", type text},
            {"AccountId", type text},
            {"StoreId", type text},
            {"SalesRepId", type text},
            {"SourceId", type text},
            {"ModelId", type text},
            {"CreatedDate", type date},
            {"Stage", type text},
            {"StageEnteredDate", type date},
            {"CloseDate", type date},
            {"IsClosed", type logical},
            {"IsWon", type logical},
            {"ExpectedRevenue", Currency.Type},
            {"Probability", type number},
            {"WeightedRevenue", Currency.Type},
            {"TDScheduledHours", type number},
            {"IsTDSLA48hMet", type logical},
            {"FollowUpDays", Int64.Type},
            {"IsFollowUpSLA7dMet", type logical},
            {"LastContactDate", type date},
            {"IsLTPSLA30dMet", type logical},
            {"IsPublicPool", type logical},
            {"IsReactivated", type logical},
            {"PublicPoolDate", type date},
            {"DelayReason", type text},
            {"DeclineReason", type text}
        },
        "en-NZ"
    )
in
    ChangedTypes
