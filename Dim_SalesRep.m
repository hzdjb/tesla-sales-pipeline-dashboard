// Power Query (M) for table: Dim_SalesRep
// Paste into: Home > Transform data > New Source > Blank Query > Advanced Editor, then rename the query to "Dim_SalesRep".
// Depends on the text parameter "DataFolder" (see DataFolder.m).
let
    Source = Csv.Document(
        File.Contents(DataFolder & "Dim_SalesRep.csv"),
        [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
    ),
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    // Schema contract: keep only the columns the model uses; fail loudly if one is missing
    SelectedColumns = Table.SelectColumns(PromotedHeaders, {"SalesRepId", "RepName", "StoreId", "Role", "HireDate", "LeaveDate", "TenureMonths", "ManagerName", "IsActive"}, MissingField.Error),
    // Empty CSV cells become null before typing, so optional fields never raise type errors
    BlankToNull = Table.TransformColumns(SelectedColumns, {}, each if _ = "" then null else _),
    ChangedTypes = Table.TransformColumnTypes(
        BlankToNull,
        {
            {"SalesRepId", type text},
            {"RepName", type text},
            {"StoreId", type text},
            {"Role", type text},
            {"HireDate", type date},
            {"LeaveDate", type date},
            {"TenureMonths", Int64.Type},
            {"ManagerName", type text},
            {"IsActive", type logical}
        },
        "en-NZ"
    )
in
    ChangedTypes
