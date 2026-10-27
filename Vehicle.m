// Power Query (M) for table: Vehicle
// Paste into: Home > Transform data > New Source > Blank Query > Advanced Editor, then rename the query to "Vehicle".
// Depends on the text parameter "DataFolder" (see DataFolder.m).
let
    Source = Csv.Document(
        File.Contents(DataFolder & "Vehicle.csv"),
        [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
    ),
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    // Schema contract: keep only the columns the model uses; fail loudly if one is missing
    SelectedColumns = Table.SelectColumns(PromotedHeaders, {"VehicleId", "OpportunityId", "ModelId", "Colour", "Wheels", "OrderDate", "DeliveryDate", "PriceNZD"}, MissingField.Error),
    // Empty CSV cells become null before typing, so optional fields never raise type errors
    BlankToNull = Table.TransformColumns(SelectedColumns, {}, each if _ = "" then null else _),
    ChangedTypes = Table.TransformColumnTypes(
        BlankToNull,
        {
            {"VehicleId", type text},
            {"OpportunityId", type text},
            {"ModelId", type text},
            {"Colour", type text},
            {"Wheels", type text},
            {"OrderDate", type date},
            {"DeliveryDate", type date},
            {"PriceNZD", Currency.Type}
        },
        "en-NZ"
    )
in
    ChangedTypes
