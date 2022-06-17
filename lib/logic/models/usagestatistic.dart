class UsageStatistic {
  int alramUseCount;
  int eventsUseCount;
  int calenderUseCount;
  int financesUseCount;
  int mapUseCount;
  int calcUseCount;
  int timerUseCount;
  int countDownTimerUseCount;
  int compassUseCount;

  UsageStatistic({
    this.alramUseCount = 0,
    this.eventsUseCount = 0,
    this.calenderUseCount = 0,
    this.financesUseCount = 0,
    this.mapUseCount = 0,
    this.calcUseCount = 0,
    this.timerUseCount = 0,
    this.countDownTimerUseCount = 0,
    this.compassUseCount = 0,
  });

  factory UsageStatistic.fromMap(Map<String, dynamic> json) => UsageStatistic(
        alramUseCount: json["alramUseCount"],
        eventsUseCount: json["eventsUseCount"],
        calenderUseCount: json["calenderUseCount"],
        financesUseCount: json["financesUseCount"],
        mapUseCount: json["mapUseCount"],
        calcUseCount: json["calcUseCount"],
        timerUseCount: json["timerUseCount"],
        countDownTimerUseCount: json["countDownTimerUseCount"],
        compassUseCount: json["compassUseCount"],
      );

  Map<String, dynamic> toMap() => {
        "alramUseCount": alramUseCount,
        "eventsUseCount": eventsUseCount,
        "calenderUseCount": calenderUseCount,
        "financesUseCount": financesUseCount,
        "mapUseCount": mapUseCount,
        "calcUseCount": calcUseCount,
        "timerUseCount": timerUseCount,
        "countDownTimerUseCount": countDownTimerUseCount,
        "compassUseCount": compassUseCount,
      };
}
