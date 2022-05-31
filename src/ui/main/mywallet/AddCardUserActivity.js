import React, {
  Component
} from 'react';
import {
  SafeAreaView,
  Platform,
  StyleSheet,
  Text,
  View,
  ImageBackground,
  Image,
  TextInput,
  FlatList,
  Button,
  TouchableOpacity,
  TouchableHighlight,
  ScrollView,
  StatusBar,
  AsyncStorage,
  StackAction,
  NavigationActions,
  DeviceEventEmitter,
  Dimensions,
  NativeModules
} from 'react-native';

import TitleBar from '../../../widget/TitleBar';

import ProgressBar from '../../../widget/ProgressBar';

import WebserviceUtil from '../../../uitl/WebserviceUtil';

import { Loading } from '../../../widget/Loading';

import { toastShort } from '../../../uitl/ToastUtils';

import DateUtil from '../../../uitl/DateUtil';

import DeviceStorage from '../../../uitl/DeviceStorage';

import IparInput from '../../../widget/IparInput';

import CoverLayer from '../../../widget/xpop/CoverLayer';

import CheckBox from 'react-native-check-box'

import StringUtils from '../../../uitl/StringUtils';

import Contacts from 'react-native-contacts';

let nativeBridge = NativeModules.NativeBridge;

export default class AddCardUserActivity extends Component {

  constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       userBean:undefined,
       show_user:[], // 展示的用户
       contacts:[], // 本地用户
       cct_user:[], // cct 用户 
       seach_text:undefined,
       second:3, //搜索中延迟3秒请求后台
    }
  }

  UNSAFE_componentWillMount(){

  
    DeviceStorage.get('head_company_id').then((company_id) => {

      if (company_id) {
        this.setState({
            head_company_id: company_id,
          });
      }else {
        this.setState({
            head_company_id: '97',
          });

      }
    });

    DeviceStorage.get('UserBean').then((user_bean) => {

      this.setState({
          userBean: user_bean,
      });

    });

    this.getAllContacts();

  }


  componentWillUnmount(){

    this.timer && clearInterval(this.timer); 
  }

  setSecondInterval(){

    this.timer && clearInterval(this.timer); 

    this.timer = setInterval(() => {
      
        if (this.state.second == 0) {
           this.timer && clearInterval(this.timer); 
           this.searchClientsByFields();
        }else {
            var new_second = this.state.second - 1;
            this.setState({
               second : new_second, 
            });

        }


    }, 1000);

  }




  getAllContacts(){


    var temporary = this;
    Contacts.getAll().then(contacts => {

        if (contacts) { 
          temporary.setState({
              contacts:contacts,
          });

        }

    });

  }


   _renderItem = (item) => {


    var name = '';


    if (item.item.givenName != undefined) {

        name += (item.item.givenName);
    }


    if (item.item.familyName != undefined) {

        if (name.length > 0) {

           name += (' ' + item.item.familyName);

        }else {

          name += (item.item.familyName);

        }

    }

      return (

        <View style = {styles.view_item_contacts}>

            <View style = {{flex:1}}>

                <Text style = {[styles.text_edit_title,{marginTop:8}]}>{name}</Text>

                <Text style = {[styles.text_edit_title,{color:'#828282',marginTop:3}]}>{(item.item.phoneNumbers && item.item.phoneNumbers.length > 0) ? item.item.phoneNumbers[0].number : ''}</Text>
            </View>


            <TouchableOpacity
                 activeOpacity = {0.8}
                 onPress={this.clickAddOrInvite.bind(this,item)}>
                  <Text style = {[styles.text_edit_title,{color:'#C44729',padding:4}]}>{item.item.cct_user_id ? 'Add' : 'Invite'}</Text>
           </TouchableOpacity>      

           


        </View>

      );

  }
  //陈三

  clickAddOrInvite(item){

    if (item.item.cct_user_id != undefined) {

      //add
      this.showAddPopup(item);

    }else {

      //Invite
      nativeBridge.openNativeVc("ReferFriendController",null);
    }


  }


  showAddPopup(item){


             // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                          <Text style = {[styles.text_popup_title]}>Are you sure you want to add this user?</Text>


                           <View style = {styles.xpop_cancel_confim}>

                            <TouchableOpacity   
                               style = {styles.xpop_touch}   
                               activeOpacity = {0.8}
                               onPress={this.clickLogoutPopCancel.bind(this)}>


                                <View style = {[styles.xpop_item,{backgroundColor:'#e0e0e0'}]}>

                                  <Text style = {[styles.xpop_text,{color:'#333'}]}>Cancel</Text>

                               </View>


                            </TouchableOpacity>   



                            <TouchableOpacity
                               style = {styles.xpop_touch}    
                               activeOpacity = {0.8}
                               onPress={this.clickLogoutPopConfirm.bind(this,item)}>

                                <View style = {[styles.xpop_item,{backgroundColor:'#C44729'}]}>

                                  <Text style = {[styles.xpop_text,{color:'#fff'}]}>Sure</Text>

                              </View>

                            </TouchableOpacity>   

                                                   
                          </View>

                          
                        </View>
                    )
                },
            ()=>this.coverLayer.hide(),
            CoverLayer.popupMode.bottom);


  }


  clickLogoutPopCancel(){

    this.coverLayer.hide();

  }

  clickLogoutPopConfirm(item){

    this.coverLayer.hide();

    this.saveCardFriend(item);


  }


  saveCardFriend(item){


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
    '<v:Header />'+
    '<v:Body><n0:saveCardFriend id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<data i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
    '<item><key i:type="d:string">card_owner_id</key><value i:type="d:string">'+ this.state.userBean.id +'</value></item>'+
    '<item><key i:type="d:string">trans_limit</key><value i:type="d:string">-1</value></item>'+
    '<item><key i:type="d:string">friend_id</key><value i:type="d:string">'+ item.item.cct_user_id +'</value></item>'+
    '</data>'+
    '<logData i:type="n2:Map" xmlns:n2="http://xml.apache.org/xml-soap">'+
    '<item><key i:type="d:string">ip</key><value i:type="d:string"></value></item>'+
    '<item><key i:type="d:string">create_uid</key><value i:type="d:string">'+ this.state.userBean.user_id +'</value></item>'+
    '</logData></n0:saveCardFriend></v:Body></v:Envelope>';


    var temporary = this;
    Loading.show();
    WebserviceUtil.getQueryDataResponse('voucher','saveCardFriendResponse',data, function(json) {

        
        if (json && json.success == 1) {

          temporary.addUserInWallet(item);

        }else {
           Loading.hidden();
          toastShort('Add User Card Failed');
        }

           
    });      
      
  }

  addUserInWallet(item){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
    '<v:Header />'+
    '<v:Body><n0:saveCardFriend id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<data i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
    '<item><key i:type="d:string">card_owner_id</key><value i:type="d:string">'+ this.state.userBean.id +'</value></item>'+
    '<item><key i:type="d:string">trans_limit</key><value i:type="d:string">-1</value></item>'+
    '<item><key i:type="d:string">friend_id</key><value i:type="d:string">'+ item.item.cct_user_id +'</value></item>'+
    '</data>'+
    '<logData i:type="n2:Map" xmlns:n2="http://xml.apache.org/xml-soap">'+
    '<item><key i:type="d:string">ip</key><value i:type="d:string"></value></item>'+
    '<item><key i:type="d:string">create_uid</key><value i:type="d:string">'+ this.state.userBean.user_id +'</value></item>'+
    '</logData></n0:saveCardFriend></v:Body></v:Envelope>';


    var temporary = this;
    WebserviceUtil.getQueryDataResponse('notifications','addUserInWalletResponse',data, function(json) {

    
      

           
    });    
    
    Loading.hidden();
    toastShort('Add User Card Successfull');
    DeviceEventEmitter.emit('user_card','ok');

  }



  searchClientsByFields(){


    if (this.state.seach_text == undefined || this.state.seach_text.length == 0) {
      return;
    }


    var search_text = this.state.seach_text.replaceAll(' ','');


     var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body>'+
     '<n0:searchClientsByFields id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
     '<companyId i:type="d:string">'+ this.state.head_company_id + '</companyId>'+
     '<ownerId i:type="d:string">'+ this.state.userBean.id +'</ownerId>'+
     '<searchData i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
     '<item><key i:type="d:string">mobile</key><value i:type="d:string">'+ search_text +'</value></item>'+
     '</searchData>'+
     '</n0:searchClientsByFields></v:Body></v:Envelope>';

    var temporary = this;
    Loading.show();

    console.error(data);
    WebserviceUtil.getQueryDataResponse('client','searchClientsByFieldsResponse',data, function(json) {


        Loading.hidden();
        if (json && json.success == 1) {

            temporary.searchChPhoneUser(json.data);
        }else {
           temporary.searchChPhoneUser([]);
        }

           
    });      
      
  }

  matchPhone(show_users){


    var items = '';

    for (var i = 0; i < show_users.length; i++) {
        var contact =  show_users[i];

        var phone = '';

        if (contact.phoneNumbers && contact.phoneNumbers.length > 0) {

            phone = contact.phoneNumbers[0].number.replaceAll('(','').replaceAll(')','').replaceAll('-','').replaceAll(' ','').replaceAll('+65','').toUpperCase();
        }

        items +=  ('<item><key i:type="d:string">0</key><value i:type="d:string">'+ phone +'</value></item>');

    }



    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
    '<v:Header />'+
    '<v:Body><n0:matchPhone id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<data i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
    items +
    '</data>'+
    '<clientId i:type="d:string">'+ this.state.userBean.id +'</clientId>'+
    '</n0:matchPhone></v:Body></v:Envelope>';


    var temporary = this;
    Loading.show();

    WebserviceUtil.getQueryDataResponse('client','matchPhoneResponse',data, function(json) {

    
        Loading.hidden();
        if (json && json.success == 1) {

            temporary.clearDataSeach(show_users,json.data);
        }else {
           temporary.clearDataSeach(show_users,[]);
        }

           
    });      

  }


  clearDataSeach(show_users,cct_users){

      for (var i = 0; i < show_users.length; i++) {
         var contact = show_users[i];

         var phone = '';
        if (contact.phoneNumbers && contact.phoneNumbers.length > 0) {

            phone = contact.phoneNumbers[0].number.replaceAll('(','').replaceAll(')','').replaceAll('-','').replaceAll(' ','').replaceAll('+65','').toUpperCase();

        }

         for (var j = 0; j < cct_users.length; j++) {
           var cct_user = cct_users[j];

           if (cct_user && cct_user.phone && phone == cct_user.phone) {

              show_users[i].cct_user_id = cct_user.id ;

           }

         }
      }

     this.setState({
        show_user:show_users,
      });

  }




  searchChPhoneUser(){

    var text = this.state.seach_text.replaceAll(' ','').toUpperCase();


    var show_users = [];

    if (this.state.contacts) {

      for (var i = 0; i < this.state.contacts.length; i++) {
        var contact  = this.state.contacts[i];

        var name = '';

        if (contact.givenName != undefined) {

            name += (contact.givenName.replaceAll(' ','').toUpperCase());
        }

        if (contact.familyName != undefined) {
            name += (contact.familyName.replaceAll(' ','').toUpperCase());
        }

        name.replaceAll(' ','').toUpperCase();



        var phone = '';

        if (contact.phoneNumbers && contact.phoneNumbers.length > 0) {

            phone = contact.phoneNumbers[0].number.replaceAll('(','').replaceAll(')','').replaceAll('-','').replaceAll(' ','').replaceAll('+65','').toUpperCase();

        }

       
        if (name.search(text) != -1 || phone.search(text) != -1 ) {

              show_users.push(contact);
        }

      }
    }

    this.matchPhone(show_users);

  }





  _contactsView(){


    if (this.state.show_user && this.state.show_user.length > 0) {


      return (

         <View style = {styles.view_contacts}>


              <FlatList
                style = {styles.flat}
                ref = {(flatList) => this._flatList = flatList}
                renderItem = {this._renderItem}
                onEndReachedThreshold={0}
                keyExtractor={(item, index) => index.toString()}
                data={this.state.show_user}/>

         </View>


      );



    }else {

      return (

        <View style = {styles.view_contacts}>

            <Text style = {styles.text_contacts}>Contact not found</Text>

        </View>

      );

    }


  }


  render() {

    const { navigation } = this.props;

    return(

      <View style = {styles.bg}>

        <StatusBar barStyle="light-content" backgroundColor='#FFFFFF' translucent={false} />

        <SafeAreaView style = {styles.afearea} >

           <TitleBar
              title = {''} 
              navigation={navigation}
              hideLeftArrow = {true}
              hideRightArrow = {false}
              extraData={this.state}/>


           <View style = {styles.view_head}>

              <Text style = {styles.text_title}>Add Users</Text>

               <Text style = {styles.text_content}>Allow a loved one to use your CCT Card. Search them via Mobile Number</Text>

           
           </View>   


           <View style = {styles.view_content}> 


              <Text style = {styles.text_edit_title}>Enter Name or Contact Number</Text>


               <TextInput 
                  style = {styles.text_input}
                  ref='intput_amount'
                  placeholder='Name or Number'
                  multiline = {false}
                  value = {this.state.amount} 
                  onChangeText={(text) => {
                     this.setState({
                        seach_text:text,
                     });
                    }  
                  }
                  returnKeyType = 'search'
                  returnKeyLabel = 'Search'
                  onSubmitEditing = {e => {
                    this.searchChPhoneUser();
                  }}

                  />

              <View style = {styles.view_line}/>


              <Text style = {styles.text_contacts}>Contacts</Text>


              {this._contactsView()}

           
           </View>    


        </SafeAreaView>

        <SafeAreaView style = {styles.afearea_foot} />

        <CoverLayer ref={ref => this.coverLayer = ref}/>


      </View>

    );

  }
}

const styles = StyleSheet.create({
  bg: {
    flex:1,
    backgroundColor:'#FFFFFF'
  },
   afearea:{
    flex:1,
    backgroundColor:'#145A7C'
  },
  afearea_foot:{
    flex:0,
    backgroundColor:'#FFFFFF'
  },
   view_content:{
    padding:24,
    marginTop:5,
    flex:1,
    backgroundColor:'#FFFFFF',
     borderTopLeftRadius:16,
    borderTopRightRadius:16
  },
  view_head:{
    width:'100%',
     padding:24,
  },
  text_title:{
    fontSize:24,
    fontWeight:'bold',
    color:'#FFFFFF',
  },
  text_content:{
     marginTop:5,
    fontSize:16,
    color:'#FFFFFF',
  },
  text_edit_title:{
    fontSize:14,
    fontWeight:'bold',
    color:'#333333',
  },
  text_input:{
    marginTop:5,
    width:'100%',
    color:'#333333',
    fontSize:14,
  },
  view_line:{
    marginTop:8,
    width:'100%',
    backgroundColor:'#E0e0e0',
    height:1,
  },
  text_contacts:{
    marginTop:32,
    fontSize:14,
    fontWeight:'bold',
    color:'#828282',
  },
  view_contacts:{
    flex:1,
    justifyContent: 'center',
    alignItems: 'center',
   
  },
  flat:{
    width:'100%',
    flex:1
  },
  view_item_contacts:{
    flex:1,
    width:'100%',
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center'
  },
  view_popup_bg :{
    width:'100%',
    padding:24,
    backgroundColor:'#FFFFFF',
    borderTopLeftRadius:16,
    borderTopRightRadius:16,
    justifyContent: 'center',
    alignItems: 'center'
  },
  text_popup_title:{
    width:'100%',
    color:'#145A7C',
    fontSize:18,
    textAlign :'center',
    fontWeight: 'bold',
  },
   next_layout:{
    width:'100%'
  },
  xpop_cancel_confim:{
    marginTop:31,
    width:'100%',
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom:74,
  },
  xpop_item:{
    borderRadius: 50,
    height:44,
   
    justifyContent: 'center',
    alignItems: 'center',
  },
  xpop_touch:{
     width:'48%',

  },

});



