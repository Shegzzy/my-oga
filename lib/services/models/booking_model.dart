//Creating User Model

import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String? id;
  final String? driver_id;
  final String? payment_method;
  final String? additional_details;
  final String? dropOff_latitude;
  final String? dropOff_longitude;
  final String? pickUp_latitude;
  final String? pickUp_longitude;
  final String? created_at;
  final String? customer_name;
  final String? customer_phone;
  final String? customer_id;
  final String? pickup_address;
  final String? dropOff_address;
  final String? status;
  final String? amount;
  final String? distance;
  final String? bookingNumber;
  final String? deliveryMode;
  final String? rideType;
  final String? packageType;
  final Timestamp? timeStamp;

  const BookingModel({
    this.id,
    this.driver_id,
    this.payment_method,
    this.additional_details,
    this.dropOff_latitude,
    this.dropOff_longitude,
    this.pickUp_latitude,
    this.pickUp_longitude,
    this.created_at,
    this.customer_name,
    this.customer_phone,
    this.customer_id,
    this.pickup_address,
    this.dropOff_address,
    this.status,
    this.amount,
    this.distance,
    this.bookingNumber,
    this.deliveryMode,
    this.rideType,
    this.packageType,
    this.timeStamp,
  });

  toJson() {
    return {
      "Driver ID": driver_id,
      "Payment Method": payment_method,
      "Additional Details": additional_details,
      "DropOff Lat": dropOff_latitude,
      "DropOff Lng": dropOff_longitude,
      "PickUp Lat": pickUp_latitude,
      "PickUp Lng": pickUp_longitude,
      "Date Created": created_at,
      "Customer Name": customer_name,
      "Customer Phone": customer_phone,
      "Customer ID": customer_id,
      "PickUp Address": pickup_address,
      "DropOff Address": dropOff_address,
      "Status": status,
      "Amount": amount,
      "Distance": distance,
      "Booking Number": bookingNumber,
      "Delivery Mode": deliveryMode,
      "Ride Type": rideType,
      "Package Type": packageType,
      "timeStamp": timeStamp,
    };
  }

  ///Getting User Info Mapping

  /// Map user fetched from Firebase to UserModel

  factory BookingModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document)
  {
    final data = document.data()!;
    return BookingModel(
      id: document.id,
      payment_method: data["Payment Method"],
      additional_details: data["Additional Details"],
      driver_id: data["Driver ID"],
      dropOff_latitude: data["DropOff Lat"],
      dropOff_longitude: data["DropOff Lng"],
      pickUp_latitude: data["PickUp Lat"],
      pickUp_longitude: data["PickUp Lng"],
      created_at: data["Date Created"],
      customer_name: data["Customer Name"],
      customer_phone: data["Customer Phone"],
      customer_id: data["Customer ID"],
      pickup_address: data["PickUp Address"],
      dropOff_address: data["DropOff Address"],
      status: data["Status"],
      amount: data["Amount"],
      distance: data["Distance"],
      bookingNumber: data["Booking Number"],
      deliveryMode: data["Delivery Mode"],
      rideType: data["Ride Type"],
      packageType: data["Package Type"],
      timeStamp: data["timeStamp"],
    );
  }

}