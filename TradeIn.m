// Power Query (M) for table: TradeIn
// Paste into: Home > Transform data > New Source > Blank Query > Advanced Editor, then rename the query to "TradeIn".
// Depends on the text parameter "DataFolder" (see DataFolder.m).
let
    Source = Csv.Document(
        File.Contents(DataFolder & "TradeIn.csv"),
        [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
    ),
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    // Schema contract: keep only the columns the model uses; fail loudly if one is missing
    SelectedColumns = Table.SelectColumns(PromotedHeaders, {"TradeInId", "OpportunityId", "AppraisalDate", "Make", "VehicleYear", "OdometerKm", "AppraisedValueNZD", "Status", "StageAtAppraisal"}, MissingField.Error),
    // Empty CSV cells become null before typing, so optional fields never raise type errors
    BlankToNull = Table.TransformColumns(SelectedColumns, {}, each if _ = "" then null else _),
    ChangedTypes = Table.TransformColumnTypes(
        BlankToNull,
        {
            {"TradeInId", type text},
            {"OpportunityId", type text},
            {"AppraisalDate", type date},
            {"Make", type text},
            {"VehicleYear", Int64.Type},
            {"OdometerKm", Int64.Type},
            {"AppraisedValueNZD", Currency.Type},
            {"Status", type text},
            {"StageAtAppraisal", type text}
        },
        "en-NZ"
    )
in
    ChangedTypes
