import 'package:larba_00/common/common_package.dart';
import 'package:larba_00/domain/model/rpc/delegateInfo.dart';
import 'package:larba_00/domain/model/rpc/staking_type.dart';

class StakesData extends ChangeNotifier {
  late Stakes _stakes;
  late StakingType _stakingType;

  Stakes get stakes {
    return _stakes;
  }

  void updateStakes(Stakes stakes) {
    _stakes = stakes;
    notifyListeners();
  }

  StakingType get stakingType {
    return _stakingType;
  }

  void updateStakingType(StakingType stakingType) {
    _stakingType = stakingType;
    notifyListeners();
  }
}
