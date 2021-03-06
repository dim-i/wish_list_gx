import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wish_list_gx/core.dart';



class RegisterForm extends StatelessWidget {
  RegisterForm({Key? key}) : super(key: key);
  final UserProfileController _userProfileController = Get.find<UserProfileController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerPhone= TextEditingController();


  void _onRegister() async{
    if(!_formKey.currentState!.validate()){
      _formKey.currentState!.save();
    }else {
      _formKey.currentState!.save();
      _userProfileController.signUp(email: _controllerEmail.text.trim(), pass: _controllerPassword.text, phone: _controllerPhone.text);
      _formKey.currentState!.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            key: Key('fieldEmail'),
            validator: (value){
              if(value == '') return 'input_email' .tr;
              if (!validateEmail(value!)) return 'wrong_email' .tr;
              return null;
            },
            controller: _controllerEmail,
            decoration: _buildInputDecoration('email' .tr , Icon(iconEmail, size: 30)),
          ),
          TextFormField(
            key: Key('fieldPass'),
            validator: (value){
              if(value == '') return 'input_password' .tr;
              return null;
            },
            controller: _controllerPassword,
            decoration: _buildInputDecoration('password' .tr, Icon(iconKey, size: 30)),
          ),
          TextFormField(
            keyboardType: TextInputType.number,
            key: Key('phoneNum'),
            validator: (value){
              if(value == '') return 'input_phone' .tr;
              if (!validatePhone(value!)) return 'wrong_phone' .tr;
              return null;
            },
            controller: _controllerPhone,
            decoration: _buildInputDecoration('phone' .tr , Icon(iconPhone, size: 30)),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            key: Key('buttonRegisterSend'),
            onPressed: _onRegister,
            child: Text('sign_up'.tr),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, Icon icon) {
    return InputDecoration(
      labelText: label,
      icon: icon,
    );
  }
}
