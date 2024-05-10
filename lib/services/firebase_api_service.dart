
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../common/const/utils/convertHelper.dart';


//----------------------------------------------------------------------------------------
//
//    firebase api service
//

// ignore: non_constant_identifier_names
FROM_SERVER_DATA(data) {
  return SET_SERVER_TIME_ALL(data);
}

// ignore: non_constant_identifier_names
SET_SERVER_TIME_ALL(data) {
  if (data is Map) {
    for (var item in data.entries) {
      data[item.key] = SET_SERVER_TIME_ALL_ITEM(item.value);
    }
  } else if (data is List) {
    data = SET_SERVER_TIME_ALL_ITEM(data);
  }
  return data;
}

// ignore: non_constant_identifier_names
SET_SERVER_TIME_ALL_ITEM(data) {
  if (data is Timestamp) {
    data = SET_SERVER_TIME(data);
  } else if (data is Map) {
    data = SET_SERVER_TIME_ALL(data);
  } else if (data is List) {
    for (var i=0; i<data.length; i++) {
      data[i] = SET_SERVER_TIME_ALL_ITEM(data[i]);
    }
  }
  return data;
}

// ignore: non_constant_identifier_names
SET_SERVER_TIME(timestamp) {
  if (timestamp != null && timestamp is Timestamp) {
    // return DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000).toString(); // fix for jsonSerialize
    // LOG('--> timestamp : ${timestamp.toString()} => ${timestamp.toDate().toString()}');
    // final date = timestamp.toDate();
    // final result = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(date).toString();
    // LOG('--> SET_SERVER_TIME : ${timestamp.toString()} => $result');
    // return result;
    return timestamp.toDate().toString();
    // return {
    //   '_seconds': timestamp.seconds,
    //   '_nanoseconds': timestamp.nanoseconds,
    // };
  } else {
    return timestamp;
  }
}

// ignore: non_constant_identifier_names
TO_SERVER_DATA(data) {
  return SET_TO_SERVER_TIME_ALL(data);
}

// ignore: non_constant_identifier_names
SET_TO_SERVER_TIME_ALL(data) {
  if (data is Map) {
    if (data['_seconds'] != null) {
      return Timestamp(data['_seconds'], data['_nanoseconds']);
    }
    for (var item in data.entries) {
      if (item.key.contains('Time') && item.value is String) {
        LOG('--> SET_TO_SERVER_TIME_ALL : ${item.key} / ${item.value}');
        final tmp = DateTime.tryParse(item.value);
        if (tmp != null) {
          data[item.key] = Timestamp.fromDate(tmp);
        }
      } else {
        data[item.key] = SET_TO_SERVER_TIME_ALL_ITEM(item.value);
      }
    }
  } else if (data is List) {
    data = SET_TO_SERVER_TIME_ALL_ITEM(data);
  }
  if (data is String && data.contains('Time')) {
    final tmp = DateTime.tryParse(data);
    if (tmp != null) {
      return Timestamp.fromDate(tmp);
    }
  }
  return data;
}

// ignore: non_constant_identifier_names
SET_TO_SERVER_TIME_ALL_ITEM(data) {
  if (data is Map) {
    data = SET_TO_SERVER_TIME_ALL(data);
  } else if (data is List) {
    for (var i=0; i<data.length; i++) {
      data[i] = SET_TO_SERVER_TIME_ALL_ITEM(data[i]);
    }
  }
  return data;
}

// ignore: non_constant_identifier_names
CURRENT_SERVER_TIME() {
  Timestamp currentTime = Timestamp.fromDate(DateTime.now());
  return currentTime;
}

class FirebaseApiService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////

  final StartInfoID = '0000';
  final StartInfoCollection = 'info_app_start';

  Future<JSON?> getAppStartInfo() async {
    LOG('--> getAppStartInfo [$StartInfoID] : $firestore');
    try {
      var collectionRef = firestore.collection(StartInfoCollection);
      var querySnapshot = await collectionRef.doc(StartInfoID).get();
      if (querySnapshot.data() != null) {
        LOG('--> getAppStartInfo result : ${FROM_SERVER_DATA(
            querySnapshot.data())}');
        return FROM_SERVER_DATA(querySnapshot.data());
      }
    } catch (e) {
      LOG('--> getAppStartInfo Error : $e');
    }
    return null;
  }
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////

  final MDLInfoCollection = 'info_mdl_url';

  Future<JSON?> getMDLNetworkCheckUrl() async {
    LOG('--> getMDLNetworkCheckUrl : $firestore');
    JSON result = {};
    try {
      var collectionRef = firestore.collection(MDLInfoCollection);
      var querySnapshot = await collectionRef.get();
      for (var doc in querySnapshot.docs) {
        result[doc.data()['id']] = FROM_SERVER_DATA(doc.data());
      }
      LOG('--> getMDLNetworkCheckUrl result : ${result.toString()}');
      return result;
    } catch (e) {
      LOG('--> getMDLNetworkCheckUrl Error : $e');
    }
    return null;
  }

  final AccountCollection = 'list_account';

  Future<JSON?> getAccount(String loginType, String email) async {
    LOG('--> getAccount : $loginType / $email');
    JSON result = {};
    try {
      var collectionRef = firestore.collection(AccountCollection);
      var querySnapshot = await collectionRef.where('email', isEqualTo: email)
          .limit(1).get();
      for (var doc in querySnapshot.docs) {
        result = FROM_SERVER_DATA(doc.data());
      }
      LOG('--> getAccount result : ${result.toString()}');
      if (result.isNotEmpty) {

      }
      return result;
    } catch (e) {
      LOG('--> getAccount Error : $e');
    }
    return null;
  }

  //----------------------------------------------------------------------------------------
  //
  //    upload file..
  //

  Future? uploadImageData(imageId, data, path) async {
    try {
      var ref = storage.ref().child('$path/$imageId');
      var uploadTask = ref.putData(data);
      var snapshot = await uploadTask;
      if (snapshot.state == TaskState.success) {
        var imageUrl = await snapshot.ref.getDownloadURL();
        LOG('--> uploadImageData done : $imageUrl');
        return imageUrl;
      } else {
        return null;
      }
    } catch (e) {
      LOG('--> uploadImageData error : $e');
    }
    return null;
  }

}
