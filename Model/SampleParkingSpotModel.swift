//
//  ParkingSpot.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 21/09/2024.
//

import Foundation

struct SampleParkingSpotModel {
    let parkingSpotID: String
    let location: String
    let isAvailable: Bool
    let latitude: Double
    let longitude: Double
    
}

let parkingLorongApiApi1 : [SampleParkingSpotModel] = [
    SampleParkingSpotModel(parkingSpotID: "1", location: "", isAvailable: false, latitude: 5.9768254149597295, longitude: 116.07140946116817),
    SampleParkingSpotModel(parkingSpotID: "2", location: "", isAvailable: true, latitude: 5.976782498880927, longitude: 116.07138491711227),
    SampleParkingSpotModel(parkingSpotID: "3", location: "", isAvailable: true, latitude: 5.976739582801032, longitude: 116.07136037306017),
    SampleParkingSpotModel(parkingSpotID: "4", location: "", isAvailable: false, latitude: 5.976696666720049, longitude: 116.07133582901199),
    SampleParkingSpotModel(parkingSpotID: "5", location: "", isAvailable: false, latitude: 5.976653750637977, longitude: 116.0713112849676),
    SampleParkingSpotModel(parkingSpotID: "6", location: "", isAvailable: true, latitude: 5.976610834554819, longitude: 116.07128674092709),
    SampleParkingSpotModel(parkingSpotID: "7", location: "", isAvailable: false, latitude: 5.976567918470571, longitude: 116.07126219689042),
    SampleParkingSpotModel(parkingSpotID: "8", location: "", isAvailable: true, latitude: 5.976525002385232, longitude: 116.07123765285759),
    SampleParkingSpotModel(parkingSpotID: "9", location: "", isAvailable: false, latitude: 5.976482086298805, longitude: 116.0712131088286),
    SampleParkingSpotModel(parkingSpotID: "10", location: "", isAvailable: false, latitude: 5.976439170211291, longitude: 116.07118856480348),
    SampleParkingSpotModel(parkingSpotID: "11", location: "", isAvailable: false, latitude: 5.976396254122688, longitude: 116.0711640207822),
    SampleParkingSpotModel(parkingSpotID: "12", location: "", isAvailable: false, latitude: 5.976353338032994, longitude: 116.0711394767648),
    SampleParkingSpotModel(parkingSpotID: "13", location: "", isAvailable: true, latitude: 5.976310421942213, longitude: 116.07111493275121),
    SampleParkingSpotModel(parkingSpotID: "14", location: "", isAvailable: true, latitude: 5.976267505850343, longitude: 116.07109038874147),
    SampleParkingSpotModel(parkingSpotID: "15", location: "", isAvailable: false, latitude: 5.976224589757384, longitude: 116.07106584473563),
    SampleParkingSpotModel(parkingSpotID: "16", location: "", isAvailable: true, latitude: 5.976181673663336, longitude: 116.07104130073358),
    SampleParkingSpotModel(parkingSpotID: "17", location: "", isAvailable: false, latitude: 5.9761387575682, longitude: 116.0710167567354),
    SampleParkingSpotModel(parkingSpotID: "18", location: "", isAvailable: true, latitude: 5.976095841471976, longitude: 116.07099221274107),
    SampleParkingSpotModel(parkingSpotID: "19", location: "", isAvailable: true, latitude: 5.976052925374661, longitude: 116.07096766875058),
    SampleParkingSpotModel(parkingSpotID: "20", location: "", isAvailable: false, latitude: 5.976010009276259, longitude: 116.07094312476397),
    SampleParkingSpotModel(parkingSpotID: "21", location: "", isAvailable: true, latitude: 5.975967093176767, longitude: 116.07091858078118),
    SampleParkingSpotModel(parkingSpotID: "22", location: "", isAvailable: false, latitude: 5.9759241770761875, longitude: 116.07089403680226),
    SampleParkingSpotModel(parkingSpotID: "23", location: "", isAvailable: false, latitude: 5.9758812609745195, longitude: 116.07086949282716),
    SampleParkingSpotModel(parkingSpotID: "24", location: "", isAvailable: true, latitude: 5.975838344871764, longitude: 116.07084494885592),
    SampleParkingSpotModel(parkingSpotID: "25", location: "", isAvailable: true, latitude: 5.975795428767917, longitude: 116.07082040488855),
    SampleParkingSpotModel(parkingSpotID: "26", location: "", isAvailable: true, latitude: 5.975752512662982, longitude: 116.070795860925),
    SampleParkingSpotModel(parkingSpotID: "27", location: "", isAvailable: false, latitude: 5.9757095965569595, longitude: 116.0707713169653),
    SampleParkingSpotModel(parkingSpotID: "28", location: "", isAvailable: false, latitude: 5.975666680449847, longitude: 116.07074677300946),
    SampleParkingSpotModel(parkingSpotID: "29", location: "", isAvailable: true, latitude: 5.9756237643416465, longitude: 116.07072222905748),
    SampleParkingSpotModel(parkingSpotID: "30", location: "", isAvailable: false, latitude: 5.975580848232359, longitude: 116.07069768510932),
    SampleParkingSpotModel(parkingSpotID: "31", location: "", isAvailable: false, latitude: 5.97539162382774, longitude: 116.07057842864907),
    SampleParkingSpotModel(parkingSpotID: "32", location: "", isAvailable: true, latitude: 5.975347868417596, longitude: 116.07055543159619),
    SampleParkingSpotModel(parkingSpotID: "33", location: "", isAvailable: true, latitude: 5.975304113006496, longitude: 116.07053243454702),
    SampleParkingSpotModel(parkingSpotID: "34", location: "", isAvailable: false, latitude: 5.975260357594441, longitude: 116.07050943750151),
    SampleParkingSpotModel(parkingSpotID: "35", location: "", isAvailable: false, latitude: 5.975216602181431, longitude: 116.07048644045967),
    SampleParkingSpotModel(parkingSpotID: "36", location: "", isAvailable: false, latitude: 5.975172846767464, longitude: 116.07046344342152),
    SampleParkingSpotModel(parkingSpotID: "37", location: "", isAvailable: true, latitude: 5.975129091352543, longitude: 116.07044044638704),
    SampleParkingSpotModel(parkingSpotID: "38", location: "", isAvailable: true, latitude: 5.975085335936665, longitude: 116.07041744935624),
    SampleParkingSpotModel(parkingSpotID: "39", location: "", isAvailable: true, latitude: 5.9750415805198305, longitude: 116.07039445232911),
    SampleParkingSpotModel(parkingSpotID: "40", location: "", isAvailable: true, latitude: 5.974997825102043, longitude: 116.07037145530566),
    SampleParkingSpotModel(parkingSpotID: "41", location: "", isAvailable: true, latitude: 5.974954069683297, longitude: 116.07034845828588),
    SampleParkingSpotModel(parkingSpotID: "42", location: "", isAvailable: false, latitude: 5.974910314263597, longitude: 116.07032546126977),
    SampleParkingSpotModel(parkingSpotID: "43", location: "", isAvailable: false, latitude: 5.974866558842941, longitude: 116.07030246425738),
    SampleParkingSpotModel(parkingSpotID: "44", location: "", isAvailable: true, latitude: 5.974822803421331, longitude: 116.07027946724861),
    SampleParkingSpotModel(parkingSpotID: "45", location: "", isAvailable: true, latitude: 5.974779047998763, longitude: 116.07025647024356),
    SampleParkingSpotModel(parkingSpotID: "46", location: "", isAvailable: true, latitude: 5.974735292575241, longitude: 116.07023347324218),
    SampleParkingSpotModel(parkingSpotID: "47", location: "", isAvailable: true, latitude: 5.974691537150762, longitude: 116.07021047624445),
    SampleParkingSpotModel(parkingSpotID: "48", location: "", isAvailable: false, latitude: 5.974555004716973, longitude: 116.0701274160907),
    SampleParkingSpotModel(parkingSpotID: "49", location: "", isAvailable: true, latitude: 5.974511015146076, longitude: 116.07010487520884),
    SampleParkingSpotModel(parkingSpotID: "50", location: "", isAvailable: false, latitude: 5.974467025574261, longitude: 116.0700823343306),
    SampleParkingSpotModel(parkingSpotID: "51", location: "", isAvailable: false, latitude: 5.9743153859564035, longitude: 116.07000391544618),
    SampleParkingSpotModel(parkingSpotID: "52", location: "", isAvailable: true, latitude: 5.974272046259066, longitude: 116.06998013592897),
    SampleParkingSpotModel(parkingSpotID: "53", location: "", isAvailable: true, latitude: 5.9742287065607025, longitude: 116.06995635641555),
    SampleParkingSpotModel(parkingSpotID: "54", location: "", isAvailable: false, latitude: 5.974185366861321, longitude: 116.0699325769059),
    SampleParkingSpotModel(parkingSpotID: "55", location: "", isAvailable: false, latitude: 5.974142027160916, longitude: 116.06990879739999),
    SampleParkingSpotModel(parkingSpotID: "56", location: "", isAvailable: true, latitude: 5.9745283224741375, longitude: 116.07013113556587),
    SampleParkingSpotModel(parkingSpotID: "57", location: "", isAvailable: false, latitude: 5.974490026738377, longitude: 116.07010744025234),
    SampleParkingSpotModel(parkingSpotID: "58", location: "", isAvailable: false, latitude: 5.974451731001603, longitude: 116.07008374494211),
    SampleParkingSpotModel(parkingSpotID: "59", location: "", isAvailable: false, latitude: 5.974009434368834, longitude: 116.0698351650197),
    SampleParkingSpotModel(parkingSpotID: "60", location: "", isAvailable: false, latitude: 5.973970488371811, longitude: 116.06981256657969),
    SampleParkingSpotModel(parkingSpotID: "61", location: "", isAvailable: false, latitude: 5.974012133893079, longitude: 116.06983609258127),
    SampleParkingSpotModel(parkingSpotID: "62", location: "", isAvailable: true, latitude: 5.9739726264460185, longitude: 116.06981450185512),
    SampleParkingSpotModel(parkingSpotID: "63", location: "", isAvailable: true, latitude: 5.973933118998119, longitude: 116.06979291113207),
    SampleParkingSpotModel(parkingSpotID: "64", location: "", isAvailable: true, latitude: 5.973893611549374, longitude: 116.06977132041217),
    SampleParkingSpotModel(parkingSpotID: "65", location: "", isAvailable: true, latitude: 5.973854104099789, longitude: 116.06974972969537),
    SampleParkingSpotModel(parkingSpotID: "66", location: "", isAvailable: true, latitude: 5.973814596649359, longitude: 116.06972813898169),
    SampleParkingSpotModel(parkingSpotID: "67", location: "", isAvailable: true, latitude: 5.9737750891980905, longitude: 116.06970654827114),
    SampleParkingSpotModel(parkingSpotID: "68", location: "", isAvailable: false, latitude: 5.973735581745977, longitude: 116.06968495756368),
    SampleParkingSpotModel(parkingSpotID: "69", location: "", isAvailable: false, latitude: 5.9736960742930245, longitude: 116.06966336685934),
    SampleParkingSpotModel(parkingSpotID: "70", location: "", isAvailable: false, latitude: 5.973656566839227, longitude: 116.06964177615814),
    SampleParkingSpotModel(parkingSpotID: "71", location: "", isAvailable: false, latitude: 5.973617059384588, longitude: 116.06962018546002),
    SampleParkingSpotModel(parkingSpotID: "72", location: "", isAvailable: true, latitude: 5.973577551929107, longitude: 116.06959859476504),
    SampleParkingSpotModel(parkingSpotID: "73", location: "", isAvailable: false, latitude: 5.973538044472784, longitude: 116.06957700407315),
    SampleParkingSpotModel(parkingSpotID: "74", location: "", isAvailable: true, latitude: 5.97349853701562, longitude: 116.0695554133844),
]
