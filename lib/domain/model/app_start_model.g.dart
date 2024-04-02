// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_start_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppStartModel _$AppStartModelFromJson(Map<String, dynamic> json) =>
    AppStartModel(
      id: json['id'] as String,
      update_time: json['update_time'] as String,
      notice_message: NoticeMessageData.fromJson(
          json['notice_message'] as Map<String, dynamic>),
      version_info: (json['version_info'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, AppVersionData.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$AppStartModelToJson(AppStartModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'update_time': instance.update_time,
      'notice_message': instance.notice_message.toJson(),
      'version_info':
          instance.version_info.map((k, e) => MapEntry(k, e.toJson())),
    };

AppVersionData _$AppVersionDataFromJson(Map<String, dynamic> json) =>
    AppVersionData(
      force_update: json['force_update'] as bool,
      message:
          LanguageTextData.fromJson(json['message'] as Map<String, dynamic>),
      version: json['version'] as String,
    );

Map<String, dynamic> _$AppVersionDataToJson(AppVersionData instance) =>
    <String, dynamic>{
      'force_update': instance.force_update,
      'version': instance.version,
      'message': instance.message.toJson(),
    };

NoticeMessageData _$NoticeMessageDataFromJson(Map<String, dynamic> json) =>
    NoticeMessageData(
      id: json['id'] as String,
      show: json['show'] as bool,
      title: json['title'] as String,
      message:
          LanguageTextData.fromJson(json['message'] as Map<String, dynamic>),
      image: json['image'] == null
          ? null
          : NoticeImageData.fromJson(json['image'] as Map<String, dynamic>),
      link: json['link'] as String?,
      start_time: json['start_time'] == null
          ? null
          : DateTime.parse(json['start_time'] as String),
      end_time: json['end_time'] == null
          ? null
          : DateTime.parse(json['end_time'] as String),
    );

Map<String, dynamic> _$NoticeMessageDataToJson(NoticeMessageData instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'show': instance.show,
    'title': instance.title,
    'message': instance.message.toJson(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('image', instance.image?.toJson());
  writeNotNull('link', instance.link);
  writeNotNull('start_time', instance.start_time?.toIso8601String());
  writeNotNull('end_time', instance.end_time?.toIso8601String());
  return val;
}

ServiceData _$ServiceDataFromJson(Map<String, dynamic> json) => ServiceData(
      serviceEmail: json['serviceEmail'] as String,
      servicePhone: json['servicePhone'] as String,
      serviceUserId: json['serviceUserId'] as String,
      serviceUserName: json['serviceUserName'] as String,
      bankAccount: json['bankAccount'] as String?,
      bankTitle: json['bankTitle'] as String?,
      cancelDesc: json['cancelDesc'] as String?,
      tax: json['tax'] as String?,
    );

Map<String, dynamic> _$ServiceDataToJson(ServiceData instance) {
  final val = <String, dynamic>{
    'serviceEmail': instance.serviceEmail,
    'servicePhone': instance.servicePhone,
    'serviceUserId': instance.serviceUserId,
    'serviceUserName': instance.serviceUserName,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('bankAccount', instance.bankAccount);
  writeNotNull('bankTitle', instance.bankTitle);
  writeNotNull('cancelDesc', instance.cancelDesc);
  writeNotNull('tax', instance.tax);
  return val;
}

NoticeImageData _$NoticeImageDataFromJson(Map<String, dynamic> json) =>
    NoticeImageData(
      url: json['url'] as String,
      size_w: (json['size_w'] as num).toDouble(),
      size_h: (json['size_h'] as num).toDouble(),
    );

Map<String, dynamic> _$NoticeImageDataToJson(NoticeImageData instance) =>
    <String, dynamic>{
      'url': instance.url,
      'size_w': instance.size_w,
      'size_h': instance.size_h,
    };

LanguageTextData _$LanguageTextDataFromJson(Map<String, dynamic> json) =>
    LanguageTextData(
      text_us: json['text_us'] as String,
      text_data: (json['text_data'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$LanguageTextDataToJson(LanguageTextData instance) {
  final val = <String, dynamic>{
    'text_us': instance.text_us,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('text_data', instance.text_data);
  return val;
}
