class ApiData {
  late Map<String, dynamic> data;

  ApiData({required this.data});

  double parseDouble(dynamic value) {
    if (value == null || value == "NA") {
      return 0.0;
    }
    return double.tryParse(value.toString()) ?? 0.0;
  }

  double calculateTotalSum(List<double> sums) =>
      sums.isEmpty ? 0.0 : sums.reduce((total, current) => total + current);

  double calculateMin(List<double> sums) =>
      sums.isEmpty ? 0.0 : sums.reduce((min, current) => min < current ? min : current);

  double calculateMax(List<double> sums) =>
      sums.isEmpty ? 0.0 : sums.reduce((max, current) => max > current ? max : current);

  double calculateAverage(List<double> sums) =>
      sums.isEmpty ? 0.0 : sums.reduce((sum, current) => sum + current) / sums.length;

  String formatValue(double value) =>
      value >= 1000 ? '${(value / 1000).toStringAsFixed(2)}kW' : '${(value / 1000).toStringAsFixed(2)}kW';
}
// class MyDataModel {
//   Data? data;
//
//   MyDataModel({ this.data});
//
//   factory MyDataModel.fromJson(Map<String, dynamic> json) {
//     return MyDataModel(
//       data: Data.fromJson(json['data']),
//     );
//   }
// }
//
// class Data {
//   List<String>? dateTime;
//   List<double> freshAirV;
//   List<double> freshAirA;
//   List<double> freshAirKW;
//   List<double> freshAirPF;
//   List<double?> cabinetACV;
//   List<double?> cabinetACA;
//   List<double?> cabinetACKW;
//   List<double?> cabinetACPF;
//   List<double?> ductACV;
//   List<double?> ductACA;
//   List<double?> ductACKW;
//   List<double?> ductACPF;
//   List<double> lobbyAC1V;
//   List<double> lobbyAC1A;
//   List<double> lobbyAC1KW;
//   List<double> lobbyAC1PF;
//   List<double?> playAreaV;
//   List<double?> playAreaA;
//   List<double?> playAreaKW;
//   List<double?> playAreaPF;
//   List<double> walkInChillerV;
//   List<double> walkInChillerA;
//   List<double> walkInChillerKW;
//   List<double> walkInChillerPF;
//   List<double> exhaustV;
//   List<double> exhaustA;
//   List<double> exhaustKW;
//   List<double> exhaustPF;
//   List<double> lobbyAC2V;
//   List<double> lobbyAC2A;
//   List<double> lobbyAC2KW;
//   List<double> lobbyAC2PF;
//   List<double> lobbyAC3V;
//   List<double> lobbyAC3A;
//   List<double> lobbyAC3KW;
//   List<double> lobbyAC3PF;
//   List<double> generatorV;
//   List<double> generatorA;
//   List<double> generatorKW;
//   List<double> generatorPF;
//   List<double> mainV;
//   List<double> mainA;
//   List<double> mainKW;
//   List<double> mainPF;
//   List<double> playAreaACV;
//   List<double> playAreaACA;
//   List<double> playAreaACKW;
//   List<double> playAreaACPF;
//
//   Data({
//      this.dateTime,
//     required this.freshAirV,
//     required this.freshAirA,
//     required this.freshAirKW,
//     required this.freshAirPF,
//     required this.cabinetACV,
//     required this.cabinetACA,
//     required this.cabinetACKW,
//     required this.cabinetACPF,
//     required this.ductACV,
//     required this.ductACA,
//     required this.ductACKW,
//     required this.ductACPF,
//     required this.lobbyAC1V,
//     required this.lobbyAC1A,
//     required this.lobbyAC1KW,
//     required this.lobbyAC1PF,
//     required this.playAreaV,
//     required this.playAreaA,
//     required this.playAreaKW,
//     required this.playAreaPF,
//     required this.walkInChillerV,
//     required this.walkInChillerA,
//     required this.walkInChillerKW,
//     required this.walkInChillerPF,
//     required this.exhaustV,
//     required this.exhaustA,
//     required this.exhaustKW,
//     required this.exhaustPF,
//     required this.lobbyAC2V,
//     required this.lobbyAC2A,
//     required this.lobbyAC2KW,
//     required this.lobbyAC2PF,
//     required this.lobbyAC3V,
//     required this.lobbyAC3A,
//     required this.lobbyAC3KW,
//     required this.lobbyAC3PF,
//     required this.generatorV,
//     required this.generatorA,
//     required this.generatorKW,
//     required this.generatorPF,
//     required this.mainV,
//     required this.mainA,
//     required this.mainKW,
//     required this.mainPF,
//     required this.playAreaACV,
//     required this.playAreaACA,
//     required this.playAreaACKW,
//     required this.playAreaACPF,
//   });
//
//   factory Data.fromJson(Map<String, dynamic> json) {
//     return Data(
//       dateTime: List<String>.from(json['Date & Time']),
//       freshAirV: List<double>.from(json['Fresh Air_[V]']),
//       freshAirA: List<double>.from(json['Fresh Air_[A]']),
//       freshAirKW: List<double>.from(json['Fresh Air_[kW]']),
//       freshAirPF: List<double>.from(json['Fresh Air_[PF]']),
//       cabinetACV: List<double?>.from(json['Cabinet AC_[V]'] ?? []),
//       cabinetACA: List<double?>.from(json['Cabinet AC_[A]'] ?? []),
//       cabinetACKW: List<double?>.from(json['Cabinet AC_[kW]'] ?? []),
//       cabinetACPF: List<double?>.from(json['Cabinet AC_[PF]'] ?? []),
//       ductACV: List<double?>.from(json['Duct AC_[V]'] ?? []),
//       ductACA: List<double?>.from(json['Duct AC_[A]'] ?? []),
//       ductACKW: List<double?>.from(json['Duct AC_[kW]'] ?? []),
//       ductACPF: List<double?>.from(json['Duct AC_[PF]'] ?? []),
//       lobbyAC1V: List<double>.from(json['Lobby AC1_[V]']),
//       lobbyAC1A: List<double>.from(json['Lobby AC1_[A]']),
//       lobbyAC1KW: List<double>.from(json['Lobby AC1_[kW]']),
//       lobbyAC1PF: List<double>.from(json['Lobby AC1_[PF]']),
//       playAreaV: List<double?>.from(json['Play Area_[V]'] ?? []),
//       playAreaA: List<double?>.from(json['Play Area_[A]'] ?? []),
//       playAreaKW: List<double?>.from(json['Play Area_[kW]'] ?? []),
//       playAreaPF: List<double?>.from(json['Play Area_[PF]'] ?? []),
//       walkInChillerV: List<double>.from(json['Walk-in-Chiller_[V]']),
//       walkInChillerA: List<double>.from(json['Walk-in-Chiller_[A]']),
//       walkInChillerKW: List<double>.from(json['Walk-in-Chiller_[kW]']),
//       walkInChillerPF: List<double>.from(json['Walk-in-Chiller_[PF]']),
//       exhaustV: List<double>.from(json['Exhaust_[V]']),
//       exhaustA: List<double>.from(json['Exhaust_[A]']),
//       exhaustKW: List<double>.from(json['Exhaust_[kW]']),
//       exhaustPF: List<double>.from(json['Exhaust_[PF]']),
//       lobbyAC2V: List<double>.from(json['Lobby AC2_[V]']),
//       lobbyAC2A: List<double>.from(json['Lobby AC2_[A]']),
//       lobbyAC2KW: List<double>.from(json['Lobby AC2_[kW]']),
//       lobbyAC2PF: List<double>.from(json['Lobby AC2_[PF]']),
//       lobbyAC3V: List<double>.from(json['Lobby AC3_[V]']),
//       lobbyAC3A: List<double>.from(json['Lobby AC3_[A]']),
//       lobbyAC3KW: List<double>.from(json['Lobby AC3_[kW]']),
//       lobbyAC3PF: List<double>.from(json['Lobby AC3_[PF]']),
//       generatorV: List<double>.from(json['Generator_[V]']),
//       generatorA: List<double>.from(json['Generator_[A]']),
//       generatorKW: List<double>.from(json['Generator_[kW]']),
//       generatorPF: List<double>.from(json['Generator_[PF]']),
//       mainV: List<double>.from(json['Main_[V]']),
//       mainA: List<double>.from(json['Main_[A]']),
//       mainKW: List<double>.from(json['Main_[kW]']),
//       mainPF: List<double>.from(json['Main_[PF]']),
//       playAreaACV: List<double>.from(json['Play Area AC_[V]']),
//       playAreaACA: List<double>.from(json['Play Area AC_[A]']),
//       playAreaACKW: List<double>.from(json['Play Area AC_[kW]']),
//       playAreaACPF: List<double>.from(json['Play Area AC_[PF]']),
//     );
//   }
// }
