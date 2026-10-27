// Power Query (M) for table: Dim_Date
// Paste into: Home > Transform data > New Source > Blank Query > Advanced Editor, then rename the query to "Dim_Date".
// Depends on the text parameter "DataFolder" (see DataFolder.m).
let
    Source = Csv.Document(
        File.Contents(DataFolder & "Dim_Date.csv"),
        [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
    ),
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    // Schema contract: keep only the columns the model uses; fail loudly if one is missing
    SelectedColumns = Table.SelectColumns(PromotedHeaders, {"Date", "Year", "Quarter", "MonthNo", "MonthName", "MonthStart", "WeekOfYear", "DayOfWeek", "IsWeekend", "IsQuarterEndMonth"}, MissingField.Error),
    // Empty CSV cells become null before typing, so optional fields never raise type errors
    BlankToNull = Table.TransformColumns(SelectedColumns, {}, each if _ = "" then null else _),
    ChangedTypes = Table.TransformColumnTypes(
        BlankToNull,
        {
            {"Date", type date},
            {"Year", Int64.Type},
            {"Quarter", type text},
            {"MonthNo", Int64.Type},
            {"MonthName", type text},
            {"MonthStart", type date},
            {"WeekOfYear", Int64.Type},
            {"DayOfWeek", type text},
            {"IsWeekend", type logical},
            {"IsQuarterEndMonth", type logical}
        },
        "en-NZ"
    )
in
    ChangedTypes
