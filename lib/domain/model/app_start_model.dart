import '../../common/common_package.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:provider/provider.dart' as provider;

import '../../common/const/utils/convertHelper.dart';
import '../../common/provider/language_provider.dart';

part 'app_start_model.g.dart';

@JsonSerializable(
  explicitToJson: true,
)
class AppStartModel {
  String id;
  String update_time;
  NoticeMessageData notice_message;
  Map<String, AppVersionData> version_info;
  AppStartModel({
    required this.id,
    required this.update_time,
    required this.notice_message,
    required this.version_info,
  });

  get versionInfo {
    return version_info;
  }

  factory AppStartModel.fromJson(JSON json) => _$AppStartModelFromJson(json);
  JSON toJson() => _$AppStartModelToJson(this);
}

@JsonSerializable(
  explicitToJson: true,
)
class AppVersionData {
  bool    force_update;
  String  version;
  LanguageTextData message;
  AppVersionData({
    required this.force_update,
    required this.message,
    required this.version,
  });

  factory AppVersionData.fromJson(JSON json) => _$AppVersionDataFromJson(json);
  JSON toJson() => _$AppVersionDataToJson(this);
}

@JsonSerializable(
    explicitToJson: true,
    includeIfNull: false
)
class NoticeMessageData {
  String      id;
  bool        show;
  String      title;
  LanguageTextData  message;
  NoticeImageData?  image;
  String?           link;
  DateTime?         start_time;
  DateTime?         end_time;
  NoticeMessageData({
    required this.id,
    required this.show,
    required this.title,
    required this.message,
    this.image,
    this.link,
    this.start_time,
    this.end_time,
  });

  factory NoticeMessageData.fromJson(JSON json) => _$NoticeMessageDataFromJson(json);
  JSON toJson() => _$NoticeMessageDataToJson(this);
}

@JsonSerializable(
    explicitToJson: true,
    includeIfNull: false
)
class ServiceData {
  String      serviceEmail;
  String      servicePhone;
  String      serviceUserId;
  String      serviceUserName;
  String?     bankAccount;
  String?     bankTitle;
  String?     cancelDesc;
  String?     tax;
  ServiceData({
    required this.serviceEmail,
    required this.servicePhone,
    required this.serviceUserId,
    required this.serviceUserName,

    this.bankAccount,
    this.bankTitle,
    this.cancelDesc,
    this.tax
  });

  factory ServiceData.fromJson(JSON json) => _$ServiceDataFromJson(json);
  JSON toJson() => _$ServiceDataToJson(this);
}

@JsonSerializable()
class NoticeImageData {
  String url;
  double size_w;
  double size_h;
  NoticeImageData({
    required this.url,
    required this.size_w,
    required this.size_h,
  });

  factory NoticeImageData.fromJson(JSON json) => _$NoticeImageDataFromJson(json);
  JSON toJson() => _$NoticeImageDataToJson(this);
}

@JsonSerializable(
    includeIfNull: false
)
class LanguageTextData {
  String text_us;
  Map<String, String>? text_data;
  LanguageTextData({
    required this.text_us,
    required this.text_data,
  });

  String getText(BuildContext context) {
    final locale = provider.Provider.of<LanguageProvider>(context, listen: false)
        .getLocale;
    if (locale == null || text_data == null || !text_data!.containsKey(locale.languageCode)) {
      return text_us;
    }
    return text_data![locale.languageCode] ?? '';
  }

  factory LanguageTextData.fromJson(JSON json) => _$LanguageTextDataFromJson(json);
  JSON toJson() => _$LanguageTextDataToJson(this);
}
