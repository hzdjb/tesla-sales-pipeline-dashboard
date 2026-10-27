// Power Query (M) for table: Charging
// Paste into: Home > Transform data > New Source > Blank Query > Advanced Editor, then rename the query to "Charging".
// Depends on the text parameter "DataFolder" (see DataFolder.m).
let
    Source = Csv.Document(
        File.Contents(DataFolder & "Charging.csv"),
        [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
    ),
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    // Schema contract: keep only the columns the model uses; fail loudly if one is missing
    SelectedColumns = Table.SelectColumns(PromotedHeaders, {"ChargingId", "OpportunityId", "RequestDate", "ChargerType", "InstallStatus", "QuoteNZD", "StageAtRequest"}, MissingField.Error),
    // Empty CSV cells become null before typing, so optional fields never raise type errors
    BlankToNull = Table.TransformColumns(SelectedColumns, {}, each if _ = "" then null else _),
    ChangedTypes = Table.TransformColumnTypes(
        BlankToNull,
        {
            {"ChargingId", type text},
            {"OpportunityId", type text},
            {"RequestDate", type date},
            {"ChargerType", type text},
            {"InstallStatus", type text},
            {"QuoteNZD", Currency.Type},
            {"StageAtRequest", type text}
        },
        "en-NZ"
    )
in
    ChangedTypes
