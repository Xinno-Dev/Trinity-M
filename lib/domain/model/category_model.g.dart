// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryModel _$CategoryModelFromJson(Map<String, dynamic> json) =>
    CategoryModel(
      tagId: (json['tagId'] as num?)?.toInt(),
      value: json['value'] as String?,
    );

Map<String, dynamic> _$CategoryModelToJson(CategoryModel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('tagId', instance.tagId);
  writeNotNull('value', instance.value);
  return val;
}
