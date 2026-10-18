import GiftUI
import GiftUIDrawing
import GiftUISemanticCore
package func forward<Table: CanvasValueTable>(_ semantic: borrowing SemanticRecordStore<CanvasSemanticPayload<Table.CaptureStorage>>, values: borrowing CanvasStagedValues<SemanticRecordReference, Table>, table: borrowing Table) throws(DrawingError) { try CanvasSemanticTransfer.stage(from: semantic, into: values, table: table) }
