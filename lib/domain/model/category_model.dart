
import 'package:json_annotation/json_annotation.dart';
import 'package:larba_00/domain/model/product_item_model.dart';
import 'package:larba_00/domain/model/seller_model.dart';
import '../../common/const/utils/convertHelper.dart';

part 'category_model.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
)
class CategoryModel {
  int?    tagId;
  String? value;

  CategoryModel({
    this.tagId,
    this.value,
  });

  factory CategoryModel.fromJson(JSON json) => _$CategoryModelFromJson(json);
  JSON toJson() => _$CategoryModelToJson(this);
}
