import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:wish_list_gx/core.dart';

class ContactServiceException implements Exception {}

class ContactsXController extends GetxController{
  ContactsXController(this._firebaseRepository);

  final AuthRepositoryInterface _firebaseRepository;
  Rx<List<UserOther>> _userContactList = Rx<List<UserOther>>([]);
  PermissionStatus status = PermissionStatus.denied;
  var errorStatus = ''.obs;
  List<UserOther> get contacts => _userContactList.value;

  checkPermit()async{
    status = await Permission.contacts.status;
    if(!status.isGranted){
      status = await Permission.contacts.request();
    }
  }

  Future<List<Contact>> _getAllContactsFromDevice()async {
    List<Contact> contactList = [];
    try {
      var contacts = (await ContactsService.getContacts(
          withThumbnails: false))
          .toList();
      contactList = contacts;
    } catch (e){
      throw ContactServiceException();
    }
    return contactList;
  }

  List<UserOther> _getUserContacts(List<Contact> contactList, Map<dynamic, dynamic> allRegistredUsers){
    Map<String, UserOther> contactMaps = Map();
    for (Contact element in contactList){
      String email = '';
      String phone = '';
      if(element.emails!.isNotEmpty){
        List<Item> emailes = element.emails!.toList();
        email = emailes[0].value!;
      }
      if(element.phones!.isNotEmpty){
        List<Item> phones = element.phones!.toList();
        for(Item phoneElement in phones){
          phone = phoneElement.value.toString().replaceAll(RegExp(r'[^\d]'), '');
          String phoneN = phone;
          if (phone.length == 11) {
            if(phone.startsWith('8'))
              phoneN = phone.replaceFirst('8', '7');
          }
          if(!contactMaps.containsKey(phone)){
            if(allRegistredUsers.containsKey(phoneN))
              contactMaps[phone] =
                  UserOther.fromJson(
                      {
                        "id": allRegistredUsers[phone],
                        "userStatus": UserStatus.other,
                        "name": element.displayName?? '',
                        "email": email,
                        "phone": phone
                      }
                  );
              //     UserContact(
              //   name: element.displayName?? '',
              //   email: email,
              //   phone: phone,
              //   id: allRegistredUsers[phone],
              // );
          }
        }
      }
    }
    return contactMaps.entries.map((entry) => entry.value).toList();
  }

  getContacts()async {
    errorStatus.value = '';
    if (Get.find<UserProfileController>().
    user.value.userStatus == UserStatus.unauthenticated){
      _userContactList = Rx<List<UserOther>>([]);
     errorStatus.value = '?????????????????? ??????????????????????';
    }else {
      try {
        final contactList = await _getAllContactsFromDevice();
        final allRegistredUsers = await _firebaseRepository
            .getAllRegistredUsers();
        _userContactList.value =
            _getUserContacts(contactList, allRegistredUsers);
      } on Exception {
        errorStatus.value = '????????????';
        //return Future.error('error');
      }
    }
  }

  @override
  void onInit() async{
    await checkPermit();
    if(status.isGranted) {
      await getContacts();
    }
    super.onInit();
  }
}