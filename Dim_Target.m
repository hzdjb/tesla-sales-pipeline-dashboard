// Power Query (M) for table: Dim_Target
// Paste into: Home > Transform data > New Source > Blank Query > Advanced Editor, then rename the query to "Dim_Target".
// Depends on the text parameter "DataFolder" (see DataFolder.m).
let
    Source = Csv.Document(
        File.Contents(DataFolder & "Dim_Target.csv"),
        [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
    ),
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    // Schema contract: keep only the columns the model uses; fail loudly if one is missing
    SelectedColumns = Table.SelectColumns(PromotedHeaders, {"TargetId", "TargetMonth", "StoreId", "MetricName", "TargetValue"}, MissingField.Error),
    // Empty CSV cells become null before typing, so optional fields never raise type errors
    BlankToNull = Table.TransformColumns(SelectedColumns, {}, each if _ = "" then null else _),
    ChangedTypes = Table.TransformColumnTypes(
        BlankToNull,
        {
            {"TargetId", type text},
            {"TargetMonth", type date},
            {"StoreId", type text},
            {"MetricName", type text},
            {"TargetValue", type number}
        },
        "en-NZ"
    )
in
    ChangedTypes
