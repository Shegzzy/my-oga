import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderStatusModel {

  final String? id;
  final String? driverID;
  final String? customerID;
  final String? bookingNumber;
  final String? orderAssign;
  final String? outForPick;
  final String? arrivePick;
  final String? percelPicked;
  final String? wayToDrop;
  final String? arriveDrop;
  final String? completed;

  const OrderStatusModel({
    this.id,
    this.driverID,
    this.customerID,
    this.bookingNumber,
    this.orderAssign,
    this.outForPick,
    this.arrivePick,
    this.percelPicked,
    this.wayToDrop,
    this.arriveDrop,
    this.completed,
  });

  toJson() {
    return {
      "ID": id,
      "Driver ID": driverID,
      "Customer ID": customerID,
      "Booking Number": bookingNumber,
      "Order Assigned": orderAssign,
      "Out For PickUp": outForPick,
      "Arrive at PickUp": arrivePick,
      "Parcel Picked": percelPicked,
      "Going to DropOff": wayToDrop,
      "Arrive DropOff": arriveDrop,
      "Completed": completed,
    };
  }

  factory OrderStatusModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document)
  {
    final data = document.data()!;
    return OrderStatusModel(
      id: document.id,
      driverID: data["Driver ID"],
      customerID: data["Customer ID"],
      bookingNumber: data["Booking Number"],
      orderAssign: data["Order Assigned"],
      outForPick: data["Out For PickUp"],
      arrivePick: data["Arrive at PickUp"],
      percelPicked: data["Parcel Picked"],
      wayToDrop: data["Going to DropOff"],
      arriveDrop: data["Arrive DropOff"],
      completed: data["Completed"],
    );
  }


}