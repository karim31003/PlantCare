import 'package:flutter/material.dart';

class CheckoutControllers {
  final fullNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final streetCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final zipCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  void dispose() {
    fullNameCtrl.dispose();
    phoneCtrl.dispose();
    streetCtrl.dispose();
    cityCtrl.dispose();
    stateCtrl.dispose();
    zipCtrl.dispose();
    notesCtrl.dispose();
  }
}
