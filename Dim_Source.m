// Power Query (M) for table: Dim_Source
// Paste into: Home > Transform data > New Source > Blank Query > Advanced Editor, then rename the query to "Dim_Source".
// Depends on the text parameter "DataFolder" (see DataFolder.m).
let
    Source = Csv.Document(
        File.Contents(DataFolder & "Dim_Source.csv"),
        [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
    ),
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    // Schema contract: keep only the columns the model uses; fail loudly if one is missing
    SelectedColumns = Table.SelectColumns(PromotedHeaders, {"SourceId", "SourceName", "SourceCategory"}, MissingField.Error),
    // Empty CSV cells become null before typing, so optional fields never raise type errors
    BlankToNull = Table.TransformColumns(SelectedColumns, {}, each if _ = "" then null else _),
    ChangedTypes = Table.TransformColumnTypes(
        BlankToNull,
        {
            {"SourceId", type text},
            {"SourceName", type text},
            {"SourceCategory", type text}
        },
        "en-NZ"
    )
in
    ChangedTypes
