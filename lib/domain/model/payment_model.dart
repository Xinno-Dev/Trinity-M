
import 'package:json_annotation/json_annotation.dart';
import '../../../../domain/model/product_item_model.dart';
import '../../../../domain/model/seller_model.dart';
import '../../common/const/utils/convertHelper.dart';
import '../../main.dart';

part 'payment_model.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
)
class PaymentModel {
  String?   purchaseId;
  String?   orderId;
  String?   imgId;
  String?   type;
  String?   itemName;
  String?   userId;
  String?   userEmail;
  String?   amount;
  String?   currency;

  PaymentModel({
    this.purchaseId,
    this.orderId,
    this.imgId,
    this.type,
    this.itemName,
    this.userId,
    this.userEmail,
    this.amount,
    this.currency,
  });

  factory PaymentModel.fromJson(JSON json) => _$PaymentModelFromJson(json);
  JSON toJson() => _$PaymentModelToJson(this);
}
