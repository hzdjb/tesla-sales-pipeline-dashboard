// Power Query (M) for table: Dim_Model
// Paste into: Home > Transform data > New Source > Blank Query > Advanced Editor, then rename the query to "Dim_Model".
// Depends on the text parameter "DataFolder" (see DataFolder.m).
let
    Source = Csv.Document(
        File.Contents(DataFolder & "Dim_Model.csv"),
        [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
    ),
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    // Schema contract: keep only the columns the model uses; fail loudly if one is missing
    SelectedColumns = Table.SelectColumns(PromotedHeaders, {"ModelId", "ModelName", "ModelFamily", "BodyType", "BasePriceNZD"}, MissingField.Error),
    // Empty CSV cells become null before typing, so optional fields never raise type errors
    BlankToNull = Table.TransformColumns(SelectedColumns, {}, each if _ = "" then null else _),
    ChangedTypes = Table.TransformColumnTypes(
        BlankToNull,
        {
            {"ModelId", type text},
            {"ModelName", type text},
            {"ModelFamily", type text},
            {"BodyType", type text},
            {"BasePriceNZD", Int64.Type}
        },
        "en-NZ"
    )
in
    ChangedTypes
