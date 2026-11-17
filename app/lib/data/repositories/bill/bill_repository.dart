import '../../../domain/models/bill.dart';
import '../../../domain/models/bill_share.dart';

/// Bills of a house and how they are shared between members.
///
/// Screens and ViewModels use this abstract class. The SQLite version is
/// [BillRepositorySqlite]; a Firebase version will be added in phase 2.
abstract class BillRepository {
  /// Saves [bill] and splits its amount evenly between [memberIds], one
  /// [BillShare] per member.
  ///
  /// If [Bill.paidBy] is already set, the payer's own share is marked as paid.
  /// Throws [ArgumentError] if [memberIds] is empty or has duplicates.
  Future<void> addBill(Bill bill, List<String> memberIds);

  /// Returns the bills of the house, the one due first at the top.
  Future<List<Bill>> getBills(String houseId);

  /// Returns the shares of a bill in the order the members were given.
  Future<List<BillShare>> getShares(String billId);

  /// [memberId] paid the whole bill. Their own share counts as paid; the
  /// other members now owe their shares to them.
  Future<void> markBillPaid(String billId, String memberId);

  /// [memberId] gave their share to the member who paid the bill.
  Future<void> markSharePaid(String billId, String memberId);

  /// Deletes the bill and its shares.
  Future<void> deleteBill(String billId);
}
