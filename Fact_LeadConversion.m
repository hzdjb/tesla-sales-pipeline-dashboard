// Power Query (M) for table: Fact_LeadConversion
// Paste into: Home > Transform data > New Source > Blank Query > Advanced Editor, then rename the query to "Fact_LeadConversion".
// Depends on the text parameter "DataFolder" (see DataFolder.m).
let
    Source = Csv.Document(
        File.Contents(DataFolder & "Fact_LeadConversion.csv"),
        [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
    ),
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    // Schema contract: keep only the columns the model uses; fail loudly if one is missing
    SelectedColumns = Table.SelectColumns(PromotedHeaders, {"ConversionId", "LeadId", "OpportunityId", "AccountId", "LeadCreatedDate", "ConversionDate", "StoreId", "SalesRepId", "SourceId", "DaysToConvert"}, MissingField.Error),
    // Empty CSV cells become null before typing, so optional fields never raise type errors
    BlankToNull = Table.TransformColumns(SelectedColumns, {}, each if _ = "" then null else _),
    ChangedTypes = Table.TransformColumnTypes(
        BlankToNull,
        {
            {"ConversionId", type text},
            {"LeadId", type text},
            {"OpportunityId", type text},
            {"AccountId", type text},
            {"LeadCreatedDate", type date},
            {"ConversionDate", type date},
            {"StoreId", type text},
            {"SalesRepId", type text},
            {"SourceId", type text},
            {"DaysToConvert", Int64.Type}
        },
        "en-NZ"
    )
in
    ChangedTypes
