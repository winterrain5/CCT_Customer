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
  Button,
  TouchableOpacity,
  TouchableHighlight,
  ScrollView,
  StatusBar,
  AsyncStorage,
  StackAction,
  NavigationActions,
  DeviceEventEmitter,
  KeyboardAvoidingView,
  Dimensions,
  FlatList,
  Linking
} from 'react-native';

import TitleBar from '../../../widget/TitleBar';

import WebserviceUtil from '../../../uitl/WebserviceUtil';

import { Loading } from '../../../widget/Loading';

import { toastShort } from '../../../uitl/ToastUtils';

import DateUtil from '../../../uitl/DateUtil';

import DeviceStorage from '../../../uitl/DeviceStorage';

import IparInput from '../../../widget/IparInput';

import CoverLayer from '../../../widget/xpop/CoverLayer';

import CheckBox from 'react-native-check-box'

import StringUtils from '../../../uitl/StringUtils';

import {Card} from 'react-native-shadow-cards';

let {width, height} = Dimensions.get('window');


export default class ContactUsActivity extends Component {


  constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       userBean:undefined,
       locations:[],
       selected_locations:undefined,
       subjects_data:[],
       submit_emaile:undefined,
       submit_message:undefined,
       submit_subject:undefined,
       keyboard:false,
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

      if (user_bean) {
        this.setState({
          userBean: user_bean,
        });

      }
     
    });

    this.getTLocations();

    this.getAllSubjects();

  }


  //获取所有分店
  getTLocations(){


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header />'+
    '<v:Body><n0:getTLocations id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<pId i:type="d:string">'+ this.state.head_company_id +'</pId></n0:getTLocations></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('company','getTLocationsResponse',data, function(json) {

        if (json && json.success == 1 && json.data && json.data.length > 0) {

             

              //筛选
            var show_data  = [];

            for (var i = 0; i < json.data.length; i++) {
               var location = json.data[i];

               if (location.id == '99' || location.id == '101' || location.id == '107' || location.id == '105' || location.id == '109'|| location.id == '104') {

                  show_data.push(location);

               }
            }
            // 
             temporary.setState({
                locations:show_data,
             }); 


        }
    });      

  }

  //获取所有分类
  getAllSubjects(){

     var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body>'+
     '<n0:getAllSubjects id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
     '<companyId i:type="d:string">'+ this.state.head_company_id+'</companyId>'+
     '</n0:getAllSubjects></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('help-manager','getAllSubjectsResponse',data, function(json) {

        if (json && json.success == 1 && json.data && json.data.length > 0) {


            temporary.setState({
                subjects_data:json.data,
             }); 

        }
    });      

  }








  _renderItem = (item) => {

   
       return (

          <View style = {{width:'100%'}}>


              <Card  cornerRadius={16} opacity={0.1} elevation={4}  style = {{width:width - 64, padding:16,margin:8}} >

                  <View style = {{width:'100%'}}>



                      <TouchableOpacity
                        onPress={this.clickOpenlocation.bind(this,item)}>

                        <View style = {styles.view_item_head}>

                             <Image style = {{width:24,height:24}} 
                                  resizeMode = 'contain' 
                                  source={require('../../../../images/locationxxxhdpi.png')}/>  


                            <Text style = {styles.text_item_name}>{item.item.alias_name}</Text>


                             <Image style = {{width:12,height:8,marginTop:8}} 
                                  resizeMode = 'contain' 
                                  source={ (this.state.selected_locations && this.state.selected_locations.id == item.item.id) ? require('../../../../images/vector_1231.png') : require('../../../../images/dawn_1231.png')}/>  
            

                        </View>


                      </TouchableOpacity>   

                      
                      {this._locationsView(item)}



                  </View>

              </Card>



          </View>

        );

   
  }


  clickOpenlocation(item){

    if (this.state.selected_locations && this.state.selected_locations.id == item.item.id ) {

      this.setState({
        selected_locations:undefined,
      });

    }else {
      this.setState({
        selected_locations:item.item,
      });
    }


  }


  _locationsView(item){


     if (this.state.selected_locations && this.state.selected_locations.id == item.item.id ) {

        return (

          <View style = {{width:'100%',marginTop:16}}>


            <Text style = {styles.text_address}>{item.item.address}</Text>


            <View style = {[styles.view_open_time,{marginTop:16}]}>

                <Text style = {[styles.text_time,{fontWeight:'bold'}]}>Mon – Fri / </Text>

                <Text style = {styles.text_time} >{DateUtil.getShowHMTime(item.item.mon_fri_start) + ' - ' + DateUtil.getShowHMTime(item.item.mon_fri_end)}</Text>

            </View>


             <View style = {[styles.view_open_time,{marginTop:5}]}>

                <Text style = {[styles.text_time,{fontWeight:'bold'}]}>Sat,Sun,PH / </Text>

                <Text style = {styles.text_time} >{DateUtil.getShowHMTime(item.item.sat_sun_start) + ' - ' + DateUtil.getShowHMTime(item.item.sat_sun_end)}</Text>


            </View>


            <View style = {styles.view_line}/>


            <View style = {styles.view_open_time}>



              <TouchableOpacity
                style = {{flex:1}}
                onPress={this.clickPhone.bind(this,item)}>

                 <View style = {styles.view_phone_item}>

                     <Image style = {{width:16,height:16}} 
                        resizeMode = 'contain' 
                        source={require('../../../../images/phonexxxhdpi.png')}/> 

                     <Text style ={styles.text_phone}>{item.item.phone}</Text>    


                </View>
        
              </TouchableOpacity>

             

              <View style = {{height:'100%',width:0.5,backgroundColor:'#e0e0e0'}}/>




              <TouchableOpacity
                style = {{flex:1}}
                onPress={this.clickWhatapp.bind(this,item)}>

                 <View style = {styles.view_phone_item}>


                     <Image style = {{width:16,height:16}} 
                        resizeMode = 'contain' 
                        source={require('../../../../images/lv_dianhua.png')}/> 

                     <Text style ={styles.text_phone}>{item.item.whatapp}</Text>   


                </View>



              </TouchableOpacity>  


             

            </View>

          </View>

        );



     }else {


        return (

          <View />
        );



     }


    


  }


  clickPhone(item){


    if (!item.item || !item.item.phone) {

      return;
    }


       // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                          <Text style = {[styles.text_popup_title]}>Do you want to call {item.item.phone ? item.item.phone : ''}</Text>


                        

                           <View style = {styles.xpop_cancel_confim}>

                            <TouchableOpacity   
                               style = {styles.xpop_touch}   
                               activeOpacity = {0.8}
                               onPress={this.clickPhonePopCancel.bind(this,item)}>


                                <View style = {[styles.xpop_item,{backgroundColor:'#e0e0e0'}]}>

                                  <Text style = {[styles.xpop_text,{color:'#333'}]}>Cancel</Text>

                               </View>


                            </TouchableOpacity>   



                            <TouchableOpacity
                               style = {styles.xpop_touch}    
                               activeOpacity = {0.8}
                               onPress={this.clickPhonePopConfirm.bind(this,item)}>

                                <View style = {[styles.xpop_item,{backgroundColor:'#C44729'}]}>

                                  <Text style = {[styles.xpop_text,{color:'#fff'}]}>Sure</Text>

                              </View>

                            </TouchableOpacity>   

                                                   
                          </View>

                          
                        </View>
                    )
                },
            ()=>this.hidePopup(),
            CoverLayer.popupMode.bottom);

  }


  hidePopup(){
    this.coverLayer.hide();
    this.setState({
      keyboard:false,
    });
  }



  clickPhonePopCancel(item){

    this.hidePopup();
  }

  clickPhonePopConfirm(item){

   this.hidePopup();

    const url = 'tel:' + item.item.phone;
    Linking.canOpenURL(url)
      .then(supported => {
        if (!supported) {
            toastShort('The phone does not support dialing function!');
        }
        return Linking.openURL(url);
      })
      .catch(err => toastShort('The phone does not support dialing function!'));
  }



  clickWhatapp(item){


     if (!item.item || !item.item.whatapp) {

      return;
    }



         // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                          <Text style = {[styles.text_popup_title]}>Do you want to chat with {item.item.whatapp ? item.item.whatapp : ''}</Text>


                           <View style = {styles.xpop_cancel_confim}>

                            <TouchableOpacity   
                               style = {styles.xpop_touch}   
                               activeOpacity = {0.8}
                               onPress={this.clickPhonePopCancel.bind(this,item)}>


                                <View style = {[styles.xpop_item,{backgroundColor:'#e0e0e0'}]}>

                                  <Text style = {[styles.xpop_text,{color:'#333'}]}>Cancel</Text>

                               </View>


                            </TouchableOpacity>   



                            <TouchableOpacity
                               style = {styles.xpop_touch}    
                               activeOpacity = {0.8}
                               onPress={this.clickWhatAppPopConfirm.bind(this,item)}>

                                <View style = {[styles.xpop_item,{backgroundColor:'#C44729'}]}>

                                  <Text style = {[styles.xpop_text,{color:'#fff'}]}>Sure</Text>

                              </View>

                            </TouchableOpacity>   

                                                   
                          </View>

                          
                        </View>
                    )
                },
            ()=>this.hidePopup(),
            CoverLayer.popupMode.bottom);



  }


  clickWhatAppPopConfirm(item){

    this.hidePopup();

    const url = 'whatsapp://send?text=hello&phone=' + '65' + item.item.whatapp;
    Linking.canOpenURL(url)
      .then(supported => {
        if (!supported) {
            toastShort('You are not installed Whatapp!');
        }
        return Linking.openURL(url);
      })
      .catch(err => toastShort('You are not installed Whatapp!'));


  }


  clickSubmit(){


         // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                          <Text style = {[styles.text_popup_title]}>Fill in the Enquiry Form</Text>


                          <Text style = {[styles.text_popup_content]}>Enquiries will be submitted via Email</Text>



                          <Text style ={styles.text_popup_item_title}>Name</Text>

                          <Text style = {styles.text_popup_item_content}>{this.state.userBean ? this.state.userBean.first_name + ' ' + this.state.userBean.last_name : ''}</Text>

                          <View  style = {[styles.view_line,{marginTop:8}]}/>


                           <View style = {styles.view_iparinput}>
                              <IparInput 
                                  valueText = {this.state.submit_emaile}
                                  placeholderText={'Enter Email'}
                                  onBlur={() => {
                                    this.setState({
                                      keyboard:false,
                                    })
                                   }}
                                  onFocus={() => {
                                      this.setState({
                                        keyboard:true,
                                      })
                                  }} 
                                  onChangeText={(text) => {
                                       
                                    this.setState({submit_emaile:text})
                                  }}/>

                          </View>



                          <TouchableOpacity
                               activeOpacity = {0.8}
                               onPress={this.clickSubmitSelectSubject.bind(this)}>

                              <View style = {[styles.view_item_head,{paddingTop:16,paddingBottom:16}]}>


                                  <Text style = {[styles.text_popup_item_content,{flex:1,color:this.state.submit_subject ? '#333333' : '#828282'}]}>{this.state.submit_subject ? this.state.submit_subject.subject : 'Select subject'}</Text>

                                  
                                   <Image style = {{width:12,height:8,marginTop:8,marginRight:16}} 
                                      resizeMode = 'contain' 
                                      source={require('../../../../images/dawn_1231.png')}/>  
                
                                 
                              </View>


                          </TouchableOpacity>     

                          
                          <View  style = {[styles.view_line,{marginTop:8}]}/>


                           <View style = {styles.view_iparinput}>
                              <IparInput 
                                  valueText = {this.state.submit_message}
                                  placeholderText={'Message'}
                                  onBlur={() => {
                                    this.setState({
                                      keyboard:false,
                                    })
                                   }}
                                  onFocus={() => {
                                      this.setState({
                                        keyboard:true,
                                      })
                                  }} 
                                  onChangeText={(text) => {
                                       
                                    this.setState({submit_message:text})
                                  }}/>

                          </View>
                          
                          




                           <View style = {styles.xpop_cancel_confim}>

                            <TouchableOpacity   
                               style = {styles.xpop_touch}   
                               activeOpacity = {0.8}
                               onPress={() =>this.hidePopup()}>


                                <View style = {[styles.xpop_item,{backgroundColor:'#e0e0e0'}]}>

                                  <Text style = {[styles.xpop_text,{color:'#333'}]}>Back</Text>

                               </View>


                            </TouchableOpacity>   



                            <TouchableOpacity
                               style = {styles.xpop_touch}    
                               activeOpacity = {0.8}
                               onPress={this.clickSubmitPopConfirm.bind(this)}>

                                <View style = {[styles.xpop_item,{backgroundColor:'#C44729'}]}>

                                  <Text style = {[styles.xpop_text,{color:'#fff'}]}>Submit</Text>

                              </View>

                            </TouchableOpacity>   

                                                   
                          </View>


                          <View style = {{width:'100%',height:this.state.keyboard ? 280 : 0,}}/> 

                          
                        </View>
                    )
                },
            ()=>this.hidePopup(),
            CoverLayer.popupMode.bottom);



  }


  clickSubmitSelectSubject(){




    if (!this.state.subjects_data || this.state.subjects_data.length == 0) {

      return;
    }

    this.hidePopup();

    // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
        ()=> {
            return (
                <View style={styles.view_popup_bg}>


                  <Text style = {styles.text_popup_title}>Select Subject</Text>

                  <FlatList
                      style = {styles.flat_popup}
                      ref = {(flatList) => this._flatList = flatList}
                      renderItem = {this._subjects_renderItem}
                      onEndReachedThreshold={0}
                      keyExtractor={(item, index) => index.toString()}
                      data={this.state.subjects_data}/>

                 


                </View>
            )
        },
    ()=>this.hidePopup(),
    CoverLayer.popupMode.bottom);

  }


   _subjects_renderItem = (item) => {


      return (

        <TouchableOpacity
          style = {{width:'100%'}}
          activeOpacity = {0.8}
          onPress = {this.selectedSubjects.bind(this,item)}>

          <Text style = {[styles.text_popup_content,{textAlign:'left',color:'#333333'}]}>{item.item.subject}</Text>


          <View style = {[styles.view_item_line,{marginTop:11}]}/>


        </TouchableOpacity>  

      );

  }

  selectedSubjects(item){

    this.setState({
      submit_subject:item.item,
    });
    this.hidePopup();
    this.clickSubmit();
  }




  clickSubmitPopConfirm(){


    if (!this.state.submit_emaile || !this.state.submit_message || !this.state.submit_subject) {
      
      toastShort('Please fill in the full information！');
      return;
    }

     this.hidePopup();

     var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
     '<v:Header />'+
     '<v:Body><n0:saveClientEnquiry id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
     '<data i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
     '<item><key i:type="d:string">company_id</key><value i:type="d:string">'+ this.state.head_company_id +'</value></item>'+
     '<item><key i:type="d:string">client_submit_email</key><value i:type="d:string">'+ this.state.submit_emaile +'</value></item>'+
     '<item><key i:type="d:string">qa_content</key><value i:type="d:string">'+ this.state.submit_message +'</value></item>'+
     '<item><key i:type="d:string">subject_id</key><value i:type="d:string">'+ this.state.submit_subject.id +'</value></item>'+
     '<item><key i:type="d:string">client_id</key><value i:type="d:string">'+ this.state.userBean.id +'</value></item>'+
     '</data></n0:saveClientEnquiry></v:Body></v:Envelope>';

    var temporary = this;
    Loading.show();
    WebserviceUtil.getQueryDataResponse('help-manager','saveClientEnquiryResponse',data, function(json) {

        if (json && json.success == 1) {

          // temporary.setState({
          //   submit_emaile:undefined,
          //   submit_message:undefined,
          //   submit_subject:undefined,
          // });



          temporary.getTSystemConfig();


        }else {
          Loading.hidden();
          toastShort('Your enquiry has failed to submit!');

        }
    });      
  }


  getTSystemConfig(){


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
    '<v:Header />'+
    '<v:Body><n0:getTSystemConfig id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<companyId i:type="d:string">'+ this.state.head_company_id +'</companyId>'+
    '<columns i:type="d:string">' + 'receive_specific_email' + '</columns>'+
    '</n0:getTSystemConfig></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('system-config','getTSystemConfigResponse',data, function(json) {

        if (json && json.success == 1) {

          temporary.sendSmsForEmail(json.data.receive_specific_email);

        }else {
          Loading.hidden();
          toastShort('Your enquiry has failed to submit!');

        }
    });      

  }


  sendSmsForEmail(receive_specific_email){


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
    '<v:Header />'+
    '<v:Body><n0:sendSmsForEmail id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<params i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
    '<item><key i:type="d:string">company_id</key><value i:type="d:string">'+ this.state.head_company_id +'</value></item>'+
    '<item><key i:type="d:string">email</key><value i:type="d:string">'+ receive_specific_email +'</value></item>'+
    '<item><key i:type="d:string">from_email</key><value i:type="d:string">'+ this.state.submit_emaile +'</value></item>'+
    '<item><key i:type="d:string">message</key><value i:type="d:string">'+ this.state.submit_message +'</value></item>'+
    '<item><key i:type="d:string">title</key><value i:type="d:string">[Chien Chi Tow] Submit an enquiry</value></item>'+
    '<item><key i:type="d:string">client_id</key><value i:type="d:string">'+ this.state.userBean.id + '</value></item>'+
    '</params></n0:sendSmsForEmail></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('sms','sendSmsForEmailResponse',data, function(json) {

        Loading.hidden();
        if (json && json.success == 1) {

          temporary.setState({
            submit_emaile:undefined,
            submit_message:undefined,
            submit_subject:undefined,
          });

          toastShort('Your enquiry is submitted!');

        }else {

          toastShort('Your enquiry has failed to submit!');

        }
    });      

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

               <View style = {styles.view_content}>


                  <Text style = {styles.text_title}>Contact Us</Text>



                  <FlatList
                      ref = {(flatList) => this._flatList = flatList}
                      renderItem = {this._renderItem}
                      onEndReachedThreshold={0}
                      keyExtractor={(item, index) => index.toString()}
                      data={this.state.locations}/>

               

               </View>   


              <View style = {styles.next_view}>

                    <TouchableOpacity style = {[styles.next_layout]}  
                          activeOpacity = {0.8}
                          onPress={this.clickSubmit.bind(this)}>


                      <Text style = {styles.next_text}>Submit an enquiry</Text>

                    </TouchableOpacity>


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
    flex:1,
    backgroundColor:'#FFFFFF'
  },
  text_title:{
    fontSize:24,
    fontWeight:'bold',
    color:'#145A7C',
  },
  view_item_head:{
    width:'100%',
    flexDirection: 'row',
  },
  text_item_name:{
    flex:1,
    marginLeft:10,
     fontSize:18,
    fontWeight:'bold',
    color:'#145A7C',
  },
  text_address:{
    width:'100%',
    fontSize:16,
    color:'#4F4F4F',
  },
  view_open_time:{
    width:'100%',
    flexDirection: 'row',
  },
  text_time:{
    fontSize:16,
    color:'#4F4F4F',
  },
  view_line:{
    marginTop:16,
    width:'100%',
    height:1,
    backgroundColor:'#e0e0e0'
  },
  view_phone_item:{
    paddingTop:16,
    flex:1,
     flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
  },
  text_phone:{
    marginLeft:5,
     fontSize:16,
    fontWeight:'bold',
    color:'#145A7C',
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
  xpop_cancel_confim:{
    marginTop:32,
    marginBottom:50,
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
  xpop_text: {
    fontSize:14,
    textAlign :'center',
    fontWeight: 'bold',
  },
  xpop_touch:{
     width:'48%',

  },
  text_popup_title:{
    width:'100%',
    color:'#145A7C',
    fontSize:16,
    textAlign :'center',
    fontWeight: 'bold',
  },
  text_popup_content : {
    marginTop:16,
    width:'100%',
    color:'#828282',
    fontSize:14,
    textAlign :'center',
  },
  next_layout:{
    width:'100%',
    height:44,
    borderRadius: 50,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor:'#C44729'
  },
  next_text :{
    fontSize: 14,
    color: '#FFFFFF',
    fontWeight: 'bold',
  },
  next_view:{
    padding:24,
    width:'100%',
    backgroundColor:'#FFFFFF'
  },
  text_popup_item_title:{
    marginTop:32,
    width:'100%',
    fontSize:13,
    fontWeight: 'bold',
    color: '#333333',
  },
  text_popup_item_content:{
    width:'100%',
    fontSize: 16,
    color: '#333333',
  },
  view_iparinput:{
    width:'100%',
  },
  view_item_line:{
    backgroundColor: "#E0E0E0",
    width: '100%',
    height: 1
  },
  flat_popup:{
    width:'100%',
  }
});