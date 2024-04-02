
import 'package:url_launcher/url_launcher_string.dart';
import '../utils/convertHelper.dart';

showExplorer(String exploreUrl, String target, String type, {var isRigo = false}) {
  if (exploreUrl.isNotEmpty) {
    if (isRigo) {
      // targetUrl += '/address/detail/$target';
      exploreUrl += '/$type/detail/${target.toLowerCase()}'; // type: address, transaction
    } else {
      return;
    }
    LOG('---> showExplorer : $exploreUrl');
    launchUrlString(exploreUrl);
  }
}

