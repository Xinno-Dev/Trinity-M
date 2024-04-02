
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../common/const/utils/convertHelper.dart';

part 'account.g.dart';

@JsonSerializable()
class Account {
  String? address;
  String? name;
  String? url;
  String? nonce;
  String? balance;

  Account({this.address, this.name, this.url, this.nonce, this.balance});

  factory Account.fromJson(JSON json) => _$AccountFromJson(json);
  JSON toJson() => _$AccountToJson(this);
}
