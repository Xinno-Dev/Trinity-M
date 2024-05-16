import '../../../common/const/widget/validators_list_column.dart';
import '../../../services/json_rpc_service.dart';
import 'package:provider/provider.dart' as provider;

import '../../../common/common_package.dart';
import '../../../common/const/utils/convertHelper.dart';
import '../../../common/provider/network_provider.dart';
import '../../../domain/model/network_model.dart';
import '../../../domain/model/rpc/validator.dart';

class ValidatorsScreen extends StatelessWidget {
  ValidatorsScreen({Key? key}) : super(key: key);

  double totalStakingAmount = 0;

  Future<List<ValidatorList>> getValidatorsList(
      NetworkModel networkModel) async {
    List<ValidatorList> validatorList =
        await JsonRpcService().getValidators(networkModel);
    double sum = 0;
    for (ValidatorList validator in validatorList) {
      sum += double.parse(validator.amount!);
    }
    totalStakingAmount = sum;
    validatorList.sort((a, b) => DBL(a.amount) < DBL(b.amount) ? 1 : -1);
    for (var item in validatorList) {
      LOG('--> validator item : ${DBL(item.amount)}');
    }
    return validatorList;
  }

  @override
  Widget build(BuildContext context) {
    NetworkModel networkModel =
        provider.Provider.of<NetworkProvider>(context).networkModel;
    return Container(
      color: WHITE,
      child: SafeArea(
        child: FutureBuilder<List<ValidatorList>>(
            future: getValidatorsList(networkModel),
            builder: (BuildContext context,
                AsyncSnapshot<List<ValidatorList>> snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      ValidatorList validatorList = snapshot.data![index];
                      String shortAddress =
                          getShortAddressText(validatorList.validators!, 6);
                      String strAmount = getFormattedText(
                          value: double.parse(validatorList.amount!));
                      String stakingRatio =
                          (double.parse(validatorList.amount!) /
                                  totalStakingAmount *
                                  100)
                              .toStringAsFixed(3);

                      return ValidatorsListColumn(
                        address: shortAddress,
                        stakingRatio: stakingRatio,
                        totalAmount: strAmount,
                        dailyReward: validatorList.rewardAmount!,
                        rank: index + 1,
                      );
                    });
              } else if (snapshot.hasError) {
                print('Error: ${snapshot.error}');
                return Container();
              } else {
                return Center(
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      color: PRIMARY_90,
                    ),
                  ),
                );
              }
            }),
      ),
    );
  }
}
