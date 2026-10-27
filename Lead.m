// Power Query (M) for table: Lead
// Paste into: Home > Transform data > New Source > Blank Query > Advanced Editor, then rename the query to "Lead".
// Depends on the text parameter "DataFolder" (see DataFolder.m).
let
    Source = Csv.Document(
        File.Contents(DataFolder & "Lead.csv"),
        [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
    ),
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    // Schema contract: keep only the columns the model uses; fail loudly if one is missing
    SelectedColumns = Table.SelectColumns(PromotedHeaders, {"LeadId", "CreatedDate", "SourceId", "StoreId", "SalesRepId", "ModelId", "Status", "ConversionDate", "FirstResponseHours", "IsLeadSLA24hMet", "IsPublicPool", "PublicPoolDate", "IsReactivated", "DisqualifyReason"}, MissingField.Error),
    // Empty CSV cells become null before typing, so optional fields never raise type errors
    BlankToNull = Table.TransformColumns(SelectedColumns, {}, each if _ = "" then null else _),
    ChangedTypes = Table.TransformColumnTypes(
        BlankToNull,
        {
            {"LeadId", type text},
            {"CreatedDate", type date},
            {"SourceId", type text},
            {"StoreId", type text},
            {"SalesRepId", type text},
            {"ModelId", type text},
            {"Status", type text},
            {"ConversionDate", type date},
            {"FirstResponseHours", type number},
            {"IsLeadSLA24hMet", type logical},
            {"IsPublicPool", type logical},
            {"PublicPoolDate", type date},
            {"IsReactivated", type logical},
            {"DisqualifyReason", type text}
        },
        "en-NZ"
    )
in
    ChangedTypes
