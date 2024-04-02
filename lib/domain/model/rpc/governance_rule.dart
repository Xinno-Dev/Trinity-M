class GovernanceRule {
  String? version;
  String? maxValidatorCnt;
  String? maxValidatorStake;
  String? rewardPerPower;
  String? lazyRewardBlocks;
  String? lazyApplyingBlocks;
  String? gasPrice;
  String? minTrxGas;
  String? maxTrxGas;
  String? maxBlockGas;
  String? minVotingPeriodBlocks;
  String? maxVotingPeriodBlocks;
  String? minSelfStakeRatio;
  String? maxUpdatableStakeRatio;
  String? slashRatio;
  String? singedBlockWindow;
  String? minSignedBlocks;

  GovernanceRule(
      {this.version,
      this.maxValidatorCnt,
      this.maxValidatorStake,
      this.rewardPerPower,
      this.lazyRewardBlocks,
      this.lazyApplyingBlocks,
      this.gasPrice,
      this.minTrxGas,
      this.maxTrxGas,
      this.maxBlockGas,
      this.minVotingPeriodBlocks,
      this.maxVotingPeriodBlocks,
      this.minSelfStakeRatio,
      this.maxUpdatableStakeRatio,
      this.slashRatio,
      this.singedBlockWindow,
      this.minSignedBlocks
      });

  GovernanceRule.fromJson(Map<String, dynamic> json) {
    version = json['version'];
    maxValidatorCnt = json['maxValidatorCnt'];
    maxValidatorStake = json['maxValidatorStake'];
    rewardPerPower = json['rewardPerPower'];
    lazyRewardBlocks = json['lazyRewardBlocks'];
    lazyApplyingBlocks = json['lazyApplyingBlocks'];
    gasPrice = json['gasPrice'];
    minTrxGas = json['minTrxGas'];
    maxTrxGas = json['maxTrxGas'];
    maxBlockGas = json['maxBlockGas'];
    minVotingPeriodBlocks = json['minVotingPeriodBlocks'];
    maxVotingPeriodBlocks = json['maxVotingPeriodBlocks'];
    minSelfStakeRatio = json['minSelfStakeRatio'];
    maxUpdatableStakeRatio = json['maxUpdatableStakeRatio'];
    slashRatio = json['slashRatio'];
    singedBlockWindow = json['singedBlockWindow'];
    minSignedBlocks = json['minSignedBlocks'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['version'] = this.version;
    data['maxValidatorCnt'] = this.maxValidatorCnt;
    data['maxValidatorStake'] = maxValidatorStake;
    data['rewardPerPower'] = this.rewardPerPower;
    data['lazyRewardBlocks'] = this.lazyRewardBlocks;
    data['lazyApplyingBlocks'] = this.lazyApplyingBlocks;
    data['gasPrice'] = this.gasPrice;
    data['minTrxFee'] = this.minTrxGas;
    data['maxTrxGas'] = this.maxTrxGas;
    data['maxBlockGas'] = this.maxBlockGas;
    data['minVotingPeriodBlocks'] = this.minVotingPeriodBlocks;
    data['maxVotingPeriodBlocks'] = this.maxVotingPeriodBlocks;
    data['minSelfStakeRatio'] = this.minSelfStakeRatio;
    data['maxUpdatableStakeRatio'] = this.maxUpdatableStakeRatio;
    data['slashRatio'] = this.slashRatio;
    data['singedBlockWindow'] = this.singedBlockWindow;
    data['minSignedBlocks'] = this.minSignedBlocks;
    return data;
  }
}
