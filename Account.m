// Power Query (M) for table: Account
// Paste into: Home > Transform data > New Source > Blank Query > Advanced Editor, then rename the query to "Account".
// Depends on the text parameter "DataFolder" (see DataFolder.m).
let
    Source = Csv.Document(
        File.Contents(DataFolder & "Account.csv"),
        [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
    ),
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    // Schema contract: keep only the columns the model uses; fail loudly if one is missing
    SelectedColumns = Table.SelectColumns(PromotedHeaders, {"AccountId", "AccountName", "AccountType", "City", "Segment", "CustomerLifetimeValue", "IsExistingOwner", "CreatedDate"}, MissingField.Error),
    // Empty CSV cells become null before typing, so optional fields never raise type errors
    BlankToNull = Table.TransformColumns(SelectedColumns, {}, each if _ = "" then null else _),
    ChangedTypes = Table.TransformColumnTypes(
        BlankToNull,
        {
            {"AccountId", type text},
            {"AccountName", type text},
            {"AccountType", type text},
            {"City", type text},
            {"Segment", type text},
            {"CustomerLifetimeValue", Currency.Type},
            {"IsExistingOwner", type logical},
            {"CreatedDate", type date}
        },
        "en-NZ"
    )
in
    ChangedTypes
