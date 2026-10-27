// Power Query (M) for table: Dim_Store
// Paste into: Home > Transform data > New Source > Blank Query > Advanced Editor, then rename the query to "Dim_Store".
// Depends on the text parameter "DataFolder" (see DataFolder.m).
let
    Source = Csv.Document(
        File.Contents(DataFolder & "Dim_Store.csv"),
        [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
    ),
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    // Schema contract: keep only the columns the model uses; fail loudly if one is missing
    SelectedColumns = Table.SelectColumns(PromotedHeaders, {"StoreId", "StoreName", "City", "Island", "StoreType", "OpenDate"}, MissingField.Error),
    // Empty CSV cells become null before typing, so optional fields never raise type errors
    BlankToNull = Table.TransformColumns(SelectedColumns, {}, each if _ = "" then null else _),
    ChangedTypes = Table.TransformColumnTypes(
        BlankToNull,
        {
            {"StoreId", type text},
            {"StoreName", type text},
            {"City", type text},
            {"Island", type text},
            {"StoreType", type text},
            {"OpenDate", type date}
        },
        "en-NZ"
    )
in
    ChangedTypes
