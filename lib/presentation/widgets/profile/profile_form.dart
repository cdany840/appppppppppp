import 'package:appointment_app/config/helpers/shared/services_firebase.dart';
import 'package:appointment_app/config/helpers/shared/regex.dart';
import 'package:appointment_app/infrastructure/models/profile_model.dart';
import 'package:appointment_app/presentation/providers/form/provider_form.dart';
import 'package:appointment_app/presentation/providers/form/provider_image_input.dart';
import 'package:appointment_app/presentation/widgets/custom/style_widgets.dart';
import 'package:appointment_app/presentation/widgets/shared/date_input.dart';
import 'package:appointment_app/presentation/widgets/shared/image_input.dart';
import 'package:appointment_app/presentation/widgets/shared/toast.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProfileForm extends StatefulWidget {
  const ProfileForm({super.key, this.profileModel});
  final ProfileModel? profileModel;

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final formKey = GlobalKey<FormState>();
  final ServicesFirebase servicesFirebase = ServicesFirebase( collection: 'profile' );
  String? dropdownValue;
  final List<String> items = [ 'M', 'F', 'B' ];
  final TextEditingController contName = TextEditingController();
  final TextEditingController contSurnames = TextEditingController();
  final TextEditingController contBirthday = TextEditingController();
  final TextEditingController contPhone = TextEditingController();
  void resetForm() {
    dropdownValue = null;
    contName.clear();
    contSurnames.clear();
    contBirthday.clear();
    contPhone.clear();
  }

  @override
  void initState() {
    if (widget.profileModel != null) {
      dropdownValue = widget.profileModel!.gender!;
      contName.text = widget.profileModel!.name!;
      contSurnames.text = widget.profileModel!.surnames!;
      contBirthday.text = widget.profileModel!.birthdayDate.toString();
      contPhone.text = widget.profileModel!.phoneNumber.toString();
    }
    super.initState();
  }  

  @override
  Widget build(BuildContext context) {
    final dropDownProvider = context.watch<ProviderDropdown>();
    final selectImage = context.watch<ProviderImageInput>();
    return WillPopScope(
      onWillPop: () async {
        selectImage.resetImage();
        if (widget.profileModel == null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileForm()));
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: widget.profileModel == null ? const Text('Create Profile') : const Text('Edit Profile'),
          centerTitle: true,
          automaticallyImplyLeading: widget.profileModel == null ? false : true,
        ),
        body: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox( height: 16 ),
                  StyleTextFormField(
                    hintText: 'Rodrigo',
                    labelText: 'Name',
                    controller: contName,
                    validator: (val) {
                      if (!val!.isValidName || val.isEmpty) {
                        return 'Please, enter a valid name.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox( height: 16 ),
                  StyleTextFormField(
                    hintText: 'Medina',
                    labelText: 'Surnames',
                    controller: contSurnames,
                    validator: (val) {
                      if (!val!.isValidName || val.isEmpty) {
                        return 'Please, enter a valid surnames.';
                      }
                      return null;
                    }                  
                  ),
                  Visibility(visible: widget.profileModel == null, child: const SizedBox( height: 16 )),
                  Visibility(
                    visible: widget.profileModel == null,
                    child: DateInputField(
                      controller: contBirthday,
                      icon: Icons.calendar_today,
                      label: 'Birthday Date',
                      hint: '12/12/1212',
                      onDateSelected: (DateTime selectedDate) {
                        
                      },
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please, enter a valid date.';
                        }
                        return null;
                      }
                    ),
                  ),              
                  const SizedBox( height: 16 ),
                  StyleTextFormField(
                    keyboardType: TextInputType.phone,
                    hintText: '0000 - 000 - 000 - 000',
                    labelText: 'Phone Number',
                    controller: contPhone,
                    validator: (val) {
                      if (!val!.isValidPhone || val.isEmpty) {
                        return 'Please, enter a valid phone number.';
                      }
                      return null;
                    }
                  ),
                  const SizedBox( height: 16 ),
                  StyleDropdownButtonFormField(
                    labelText: 'Gender', 
                    hintText: 'M or F or B',
                    value: dropdownValue,
                    items: items,                  
                    validator: (val) {
                      if (val == null) {
                        return 'Please, choose a gender.';
                      }
                      return null;
                    },
                    onChange: (String? newValue) {
                      dropDownProvider.dropdownValue = newValue!;
                      dropdownValue = newValue; // ? dropDownProvider.dropdownValue
                    },
                  ),
                  const SizedBox( height: 16 ),
                  widget.profileModel != null
                  ? ImageInput( imageUrl: widget.profileModel!.image )
                  : const ImageInput( imageUrl: 'https://icons.veryicon.com/png/o/miscellaneous/two-color-icon-library/user-286.png' ),
                  const SizedBox( height: 16 ),
                  StyleElevatedButton(
                    onPressed: () async {
                      if (widget.profileModel != null) selectImage.imageUrl = widget.profileModel!.image;
                      ProfileModel profile = ProfileModel(
                        uidUser: ServicesFirebase.uid,
                        name: contName.text,
                        surnames: contSurnames.text,
                        image: selectImage.imageUrl,
                        phoneNumber: int.parse(contPhone.text),
                        birthdayDate: DateFormat("yyyy-MM-dd").parseLoose(contBirthday.text),
                        gender: dropdownValue,
                      );
                      if (formKey.currentState!.validate()) {
                        if (widget.profileModel != null) {
                          await servicesFirebase.updDocument(
                            profile.toJson(),
                            ServicesFirebase.uid
                          );                        
                        } else {
                          await servicesFirebase.insDocument(
                            profile.toJson()
                          );                        
                        }
                        Navigator.pushNamedAndRemoveUntil( // ! Remover en caso de error.
                          context, '/home', (Route<dynamic> route) => false,
                        );
                        resetForm();
                        selectImage.resetImage();
                        WidgetToast.show('Profile Save');
                      }
                    },
                    text: 'Save'
                  ),
                ],
              ),
            ),
          )
        )
      ),
    );
  }
}