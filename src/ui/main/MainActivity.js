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
  Dimensions,
  FlatList,
  NativeModules,
  NativeEventEmitter
} from 'react-native';


import MainTable from './table/MainTable';

import UserCenterTable from './table/UserCenterTable';

import SideMenu from 'react-native-side-menu';

import CoverLayer from '../../widget/xpop/CoverLayer';

import WebserviceUtil from '../../uitl/WebserviceUtil';

import { Loading } from '../../widget/Loading';

import { toastShort } from '../../uitl/ToastUtils';

let {width, height} = Dimensions.get('window');
let nativeBridge = NativeModules.NativeBridge;


const { PushManager } = NativeModules;
const MyPushManager = (Platform.OS.toLowerCase() != 'ios') ? '' : new NativeEventEmitter(PushManager);


import DeviceStorage from '../../uitl/DeviceStorage';
import {CommonActions,useNavigation} from '@react-navigation/native';



export default class MainActivity extends Component {


  constructor(props) {
    super(props);
    this.state = {
       isOpen: false,
       flag:false,
       selectedCategories:undefined,
       categories:[],
       head_company_id:'97',
       userBean:undefined,
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
  }



  //注册通知
  componentDidMount(){



      var temporary = this;
      
      this.emit =  DeviceEventEmitter.addListener('addBook',(params)=>{
            //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI

           // temporary.addBook();

           // 获取是否超过三次
           temporary.getClientCancelCount();


       });



      this.emit1 =  DeviceEventEmitter.addListener('openMenu',(params)=>{
            //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI
           temporary.setState({
              isOpen: true,

           });
       });


      this.emit2 =  DeviceEventEmitter.addListener('selectedCategories',(params)=>{
            //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI
            
           if (params) {
              var data = JSON.parse(params,'utf-8');
              temporary.setState({
                selectedCategories:data,
              });
           }else {
              temporary.setState({
                selectedCategories:undefined,
              });
           }

           temporary.getAllCategories();

       });


    this.emit3 =  DeviceEventEmitter.addListener('service_detail',(params)=>{
            //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI
           
            var service = JSON.parse(params,'utf-8');

            

            if (service) {

               const { navigation } = temporary.props;

              if (navigation) {

                if (service.source_id) {

                  navigation.navigate('BookCompletedDetailsActivity',{
                    'service':service,
                  });

                }else {

                  navigation.navigate('BookDetailsActivity',{
                    'service':service,
                  });

                }

              }
            }

       });

    this.emit4 =  DeviceEventEmitter.addListener('service_check_in',(params)=>{
            //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI
            
            if (params) {

               var service = undefined;

              try{
                  service = JSON.parse(params,'utf-8');

              }catch(e){

              }
               if (service != undefined) {
                  var codeUrl = JSON.parse(service.code_url);
                  if (service.location_id == codeUrl.id) {

                     const { navigation } = this.props;
  
                      if (navigation) {
                        navigation.navigate('CheckInConfirmBookActivity',{
                          'service':service,
                        });
                      }

                  }else {

                    toastShort('The branch you scanned does not match the branch you served!');

                  }

               }else {

                  toastShort('Failed to identify QR Code!');
               }

            }else {

                toastShort('Failed to identify QR Code!');

            }

       });


      this.emit5 =  DeviceEventEmitter.addListener('clickUseCenterItem',(params)=>{
            //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI
           
             const { navigation } = temporary.props;

            if (params == 'Services') {

              nativeBridge.openWebVc('http://info.chienchitow.com/services/');

            }else if (params == 'Conditions We Treat') {
              
              nativeBridge.openWebVc('http://info.chienchitow.com/condition-we-treat/');

            }else if (params == 'Refer a Friend') {

              nativeBridge.openNativeVc("ReferFriendController",null);

            }else if (params == 'Shop') {

              if (navigation) {
                navigation.navigate('ShopActivity');
              }

            }else if (params == 'CCT Wallet') {

              if (navigation) {
                navigation.navigate('MyWalletActivity');
              }

            }else if (params == 'Edit User') {

              nativeBridge.openNativeVc("EditProfileViewController",null);
              
            }else if (params == 'Blog') {

              nativeBridge.openNativeVc("BlogViewController",null);
              
            }else if (params == 'Contact Us') {

              nativeBridge.openNativeVc("ContactUsViewController",null);

            }else if (params == 'Frequenty Asked Questions') {

              if (navigation) {
                navigation.navigate('FrequentlyAskedQuestionsActivity');
              }

            }else if (params == 'Symptom Checker') {

              nativeBridge.openNativeVc('SymptomCheckBeginController',null);

            }else if (params == 'Madam Partum') {

              nativeBridge.openNativeVc('MadamPartumController',null);

            }else if (params == 'Our Story') {

              nativeBridge.openWebVc('http://info.chienchitow.com/about-us/');

            }else if (params == "Bookmarks") {

              nativeBridge.openNativeVc('BlogBoardsController',null);

            }else if (params == 'Appointments'){

              if (navigation) {
                navigation.navigate('Appointment');
              }
              
            }else if (params == 'Home') {

              if (navigation) {
                navigation.navigate('Home');
              }

            }else if (params == "My Orders") {

              nativeBridge.openNativeVc('MyOrdersController',null);

            }

             temporary.setState({
              isOpen: false,
           });


       });

       this.emit6 =  DeviceEventEmitter.addListener('Logout',(params)=>{
            //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI
           temporary.logout();
       });

       this.emit7 =  DeviceEventEmitter.addListener('ohter_qrcode',(url)=>{
            //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI
            
            if (url) {

              var company = undefined;

              try{
                company = JSON.parse(url,'utf-8');
              }catch(e){

              }
              NativeModules.NativeBridge.log("url"+JSON.stringify(url));
              if (company && company.id ) {
                // const { navigation } = temporary.props;
                // DeviceStorage.save('code_company', company);
                // if (navigation) {
                //   navigation.navigate('ToadyBookServicesActivity');
                // }
                temporary.navigateToToadyBook(company);
                
              }else {
                toastShort('Failed to identify QR Code!');
              }
    
            }

       });


        this.subscription = (Platform.OS.toLowerCase() != 'ios')?'':MyPushManager.addListener('UserDataChanged',() => {

            
                temporary.getTClientPartInfo();

      
          });



  }

  navigateToToadyBook(company) {
    const { navigation } = this.props;
    DeviceStorage.save('code_company', company);
    if (navigation) {
      navigation.navigate('ToadyBookServicesActivity');
    }
  }

  componentWillUnmount(){

    this.emit.remove();
    this.emit1.remove();
    this.emit2.remove();
    this.emit3.remove();
    this.emit4.remove();
    this.emit5.remove();
    this.emit6.remove();
     //移除监听
    this.subscription.remove();

  }



 getTClientPartInfo(){
  

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getTClientPartInfo id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<clientId i:type="d:string">'+ this.state.userBean.id+'</clientId>'+
    '</n0:getTClientPartInfo></v:Body></v:Envelope>';
    var temporary = this;

    WebserviceUtil.getQueryDataResponse('client','getTClientPartInfoResponse',data, function(json) {

        if (json && json.success == 1 && json.data ) {

            temporary.setState({
              userBean:json.data,
            });

            DeviceStorage.save('UserBean',json.data);
        }

    });

  }





  getClientCancelCount(){


    if (!this.state.userBean) {
      return;
    }


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
    '<v:Header /><v:Body><n0:getClientCancelCount id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<clientId i:type="d:string">'+ this.state.userBean.id +'</clientId>'+
    '</n0:getClientCancelCount></v:Body></v:Envelope>';

    var temporary = this;
    Loading.show();

   

    WebserviceUtil.getQueryDataResponse('client','getClientCancelCountResponse',data, function(json) {

    
        Loading.hidden();
        if (json && json.success == 1) {

          var cancel_count = 0;

          try{

            cancel_count = parseInt(json.data.cancel_count);

          }catch(e){

          }


          if (cancel_count < 3 ) {

             temporary.addBook();
          }else {

            temporary.showCanceBookFailed(cancel_count);

          }


           
      
        }else {

          toastShort('Failed to get the number of cancellations！');

        }
    });   

  }


  showCanceBookFailed(count){


         // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                          <Text style = {[styles.text_popup_content,{marginBottom:50}]}>If you delay cancelling more than 3 times, your in app reservation permission will be suspended.</Text>

                    

        
                        </View>
                    )
                },
            ()=>this.coverLayer.hide(),
            CoverLayer.popupMode.bottom);



  }







  getAllCategories(){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getAllCategories id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<companyId i:type="d:string">'+ this.state.head_company_id +'</companyId></n0:getAllCategories></v:Body></v:Envelope>';

    var temporary = this;
    Loading.show();

   

    WebserviceUtil.getQueryDataResponse('notifications','getAllCategoriesResponse',data, function(json) {

    
        Loading.hidden();
        if (json && json.success == 1) {

           temporary.setState({
              categories:json.data,
            });
            // 获取
            temporary.selectCategoriesPopup();
           
        }
    });   

  }


  selectCategoriesPopup(){


        // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                          <Text style = {styles.text_popup_title}>Filter Inbox</Text>

                          <FlatList
                              style = {styles.flat_popup}
                              ref = {(flatList) => this._flatList = flatList}
                              renderItem = {this._categories_renderItem}
                              onEndReachedThreshold={0}
                              keyExtractor={(item, index) => index.toString()}
                              data={this.state.categories}/>

                         


                        </View>
                    )
                },
            ()=>this.coverLayer.hide(),
            CoverLayer.popupMode.bottom);
  }


  _categories_renderItem = (item) => {

      return (

       
          <View>

             <View style = {styles.view_categories}>

                <Text style = {styles.text_popup_content}>{item.item.category_name}</Text>



                <TouchableOpacity
                   activeOpacity = {0.8}
                   onPress = {this.selectedCategoriesItem.bind(this,item)}>

                   <Image style = {styles.image_categories} 
                      resizeMode = 'contain' 
                      source={ this.isInUserCategories(item) ? require('../../../images/switch_on.png') : require('../../../images/switch_off.png')}/>


                 </TouchableOpacity>      


              </View>

              <View style = {styles.view_item_line}/>



          </View>

         

        

      );

  }


  isInUserCategories(item){

     console.error(this.state.selectedCategories);

    var isIn = false;

    if (this.state.selectedCategories) {

      for (var i = 0; i < this.state.selectedCategories.length; i++) {
          
          if (this.state.selectedCategories[i].category_id == item.item.id) {
            isIn = true;
            break;
          }
      }

    }
    return isIn;

  }

  selectedCategoriesItem(item){

    var newSelectedCategories = this.state.selectedCategories;


    if (!newSelectedCategories) {

      newSelectedCategories = [];
    }


    var postion = -1;


    for (var i = 0; i < newSelectedCategories.length; i++) {
          
          if (newSelectedCategories[i].category_id == item.item.id) {
            
            postion = i;
            break;
          }
      }


     if (postion > -1) {

      // 删
      newSelectedCategories.splice(postion,1);

     }else {

      // 增
      var addCategories = {
        'category_id' : item.item.id,
      }

      newSelectedCategories.push(addCategories);

     } 

     this.setState({
      selectedCategories:newSelectedCategories,
     })


     // 保存用户设置
     this.saveClientCategories(newSelectedCategories);

  }



  saveClientCategories(items){


    var cateIds = '';

    for (var i = 0; i < items.length; i++) {
      cateIds += ('<item><key i:type="d:string">'+ i + '</key><value i:type="d:string">'+ items[i].category_id +'</value></item>');
    }

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:saveClientCategories id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<cateIds i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
    cateIds +
    '</cateIds>'+
    '<clientId i:type="d:string">'+ this.state.userBean.id +'</clientId>'+
    '</n0:saveClientCategories></v:Body></v:Envelope>';
    var temporary = this;

    WebserviceUtil.getQueryDataResponse('notifications','saveClientCategoriesResponse',data, function(json) {

        if (json && json.success == 1) {

            DeviceEventEmitter.emit('UpNotification','ok');
             
        }

    }); 



  }



  addBook(){

       // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                            <Text style = {[styles.text_popup_title]}>Select the type of Service</Text>




                          <TouchableOpacity style = {styles.next_layout}  
                                activeOpacity = {0.8}
                                onPress={this.addTreaTment.bind(this)}>


                              <View style = {styles.view_popup_item}>


                              <View style = {styles.popup_service_more_head}>


                                <Text style = {styles.text_service_title}>Treatment</Text>

                                 <View style = {styles.popup_service_more}>


                                       <Image style = {styles.image_icon} 
                                          resizeMode = 'contain' 
                                          source={require('../../../images/hei_more.png')}/>  


                                 </View>


                              </View>


                              <Text style = {styles.text_service_content}>Treating pain management such as bone, muscle and joints issues</Text>                        

                           </View>  


                          </TouchableOpacity>    




                           <TouchableOpacity style = {styles.next_layout}  
                                activeOpacity = {0.8}
                                onPress={this.addWellness.bind(this)}>


                            <View style = {[styles.view_popup_item,{marginBottom:64}]}>


                              <View style = {styles.popup_service_more_head}>


                                <Text style = {styles.text_service_title}>Wellness</Text>

                                 <View style = {styles.popup_service_more}>


                                       <Image style = {styles.image_icon} 
                                          resizeMode = 'contain' 
                                          source={require('../../../images/hei_more.png')}/>  


                                 </View>


                              </View>


                              <Text style = {styles.text_service_content}>Rejuvenate your well being and experience a pampering time. Including specialised services for mothers</Text>                        

                           </View>   


                        </TouchableOpacity>        

                          

                   </View>
                    )
                },
            ()=>this.coverLayer.hide(),
            CoverLayer.popupMode.bottom);

  }


  addTreaTment(){

    this.coverLayer.hide();


          // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                          <Text style = {[styles.text_popup_title]}>Share more about your condition?</Text>



                          <View style = {styles.xpop_cancel_confim}>

                            <TouchableOpacity   
                               style = {styles.xpop_touch}   
                               activeOpacity = {0.8}
                               onPress={this.clickTreaTmentSkip.bind(this)}>


                                <View style = {[styles.xpop_item,{backgroundColor:'#e0e0e0'}]}>

                                  <Text style = {[styles.xpop_text,{color:'#333'}]}>Skip</Text>

                               </View>


                            </TouchableOpacity>   



                            <TouchableOpacity
                               style = {styles.xpop_touch}    
                               activeOpacity = {0.8}
                               onPress={this.clickTreaTmentYes.bind(this)}>

                                <View style = {[styles.xpop_item,{backgroundColor:'#C44729'}]}>

                                  <Text style = {[styles.xpop_text,{color:'#fff'}]}>Yes</Text>

                              </View>

                            </TouchableOpacity>   

                                                   
                        </View>                     
     
                          

                   </View>
                    )
                },
            ()=>this.coverLayer.hide(),
            CoverLayer.popupMode.bottom);



  }


  clickTreaTmentSkip(){

     this.coverLayer.hide();

     const { navigation } = this.props;
    
    if (navigation) {
      navigation.navigate('BookAppointmentActivity',{
          'select_type':0,
        });
    }
     



  }


  clickTreaTmentYes(){

    this.coverLayer.hide();


    const { navigation } = this.props;
    
    if (navigation) {
      navigation.navigate('TellUsCondition1Activity');
    }


  }





  addWellness(){

    this.coverLayer.hide();


         // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                            <Text style = {[styles.text_popup_title]}>Wellness Appointment</Text>




                          <TouchableOpacity style = {styles.next_layout}  
                                activeOpacity = {0.8}
                                onPress={this.addWellnessToDate.bind(this)}>


                              <View style = {styles.view_popup_item}>


                              <View style = {styles.popup_service_more_head}>


                                <Text style = {styles.text_service_title}></Text>

                                 <View style = {styles.popup_service_more}>


                                       <Image style = {styles.image_icon} 
                                          resizeMode = 'contain' 
                                          source={require('../../../images/hei_more.png')}/>  


                                 </View>


                              </View>


                             <View style = {[styles.view_wellness,{marginTop:-10}]}>


                                <Image style = {{width:70,height:70,marginLeft:10,marginBottom:15}} 
                                      resizeMode = 'contain' 
                                      source={require('../../../images/date_0802.png')}/> 



                                <Text style = {[styles.text_service_title,{marginLeft:40,marginTop:-10}]}>Select Date & Time</Text>      


                             </View> 

                           </View>  


                          </TouchableOpacity>    




                           <TouchableOpacity style = {styles.next_layout}  
                                activeOpacity = {0.8}
                                onPress={this.addWellnessToTherapist.bind(this)}>


                            <View style = {[styles.view_popup_item,{marginBottom:64}]}>


                              <View style = {styles.popup_service_more_head}>


                                <Text style = {styles.text_service_title}></Text>

                                 <View style = {styles.popup_service_more}>


                                       <Image style = {styles.image_icon} 
                                          resizeMode = 'contain' 
                                          source={require('../../../images/hei_more.png')}/>  


                                 </View>


                              </View>


                               <View style = {[styles.view_wellness,{marginTop:-10}]}>


                                <Image style = {{width:90,height:90,marginTop:-10}} 
                                      resizeMode = 'contain' 
                                      source={require('../../../images/graphic_app_therapist.png')}/> 



                                <Text style = {[styles.text_service_title,{marginLeft:26,marginBottom:8}]}>Select a Therapist</Text>      


                             </View>                     

                           </View>   


                        </TouchableOpacity>        

                          

                   </View>
                    )
                },
            ()=>this.coverLayer.hide(),
            CoverLayer.popupMode.bottom);




  }


  addWellnessToDate(){

    this.coverLayer.hide();


    const { navigation } = this.props;
    
    if (navigation) {
      navigation.navigate('BookAppointmentActivity',{
          'select_type':1,
        });
     
    }



  }

  addWellnessToTherapist(){

    this.coverLayer.hide();

    const { navigation } = this.props;
    
    if (navigation) {
      navigation.navigate('BookAppointmentActivity',{
          'select_type':2,
        });
     
    }

  }


  logout(){



    console.error('这是全局' + this.coverLayer);


         // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                          <Text style = {[styles.text_popup_title]}>Are you sure want to logout from you account?</Text>


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
                               onPress={this.clickLogoutPopConfirm.bind(this)}>

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


  clickLogoutPopConfirm(){

    this.coverLayer.hide();

    DeviceStorage.delete('login_name');
    DeviceStorage.delete('login_password'); 
    DeviceStorage.delete('UserBean','');  

    const { navigation } = this.props;
     if (navigation) {
        // navigation.replace('MainActivity');
        navigation.dispatch(
          CommonActions.reset({
            index: 0,
            routes: [
              { name: 'LoginActivity' },
            ],
         })
        );
      }



  }






  _closeSideMenu(){

    const isOpen = this.state.isOpen;
    const flag = this.state.flag;
    if (isOpen && flag)
        this.setState({isOpen: false, flag: false});
    else if (!isOpen && !flag) {
    } else {
        this.setState({flag: true});
    }
    
       
  }


  render() {

    return(


      <SideMenu
        menu={<UserCenterTable/>}
        openMenuOffset={width * 0.8}
        menuPosition="left"
        isOpen={this.state.isOpen}
        onChange={this._closeSideMenu.bind(this)}>


         <View style = {{flex:1}}>

           <MainTable />

          


        </View>


        <CoverLayer ref={ref => this.coverLayer = ref}/>
     

      
      </SideMenu>  




       
       

        

      );

  }

}

const styles = StyleSheet.create({
  bg: {
    flex:1,
    backgroundColor:'#FFFFFF'
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
  view_popup_item:{
    marginTop:16,
    padding:16,
    borderRadius:16,
    backgroundColor:'#FAF3EB',
    width:'100%',
  },
  popup_service_more_head:{

    flexDirection: 'row',
  

  },
  popup_service_more:{
    borderRadius:8,
    width:24,
    height:24,
    backgroundColor:'#EE8F7B',
    justifyContent: 'center',
    alignItems: 'center',
  },
  image_icon:{
    width:5,
    height:8
  },
  text_service_title:{
    flex:1,
    width:'100%',
    color:'#145A7C',
    fontSize:16,
    fontWeight: 'bold',
  },
  text_service_content:{
    marginBottom:12,
    marginTop:20,
    color:'#333',
    fontSize:14,
  },
  view_wellness:{
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center'
  },
  image_date_icon:{
    width:80,
    height:80,
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
    view_popup_bg :{
    width:'100%',
    padding:24,
    backgroundColor:'#FFFFFF',
    borderTopLeftRadius:16,
    borderTopRightRadius:16,
    justifyContent: 'center',
    alignItems: 'center'
  },
   flat_popup:{
    marginTop:24,
    width:'100%'
  },
   view_item_line:{
    backgroundColor: "#E0E0E0",
    width: '100%',
    height: 1
  },
  view_categories:{
    width:'100%',
    paddingTop:16,
    paddingBottom:16,
    flexDirection: 'row',
    justifyContent: 'space-between',
    textAlign :'center',
    fontWeight: 'bold',
  },
  text_popup_content:{
   color:'#000',
   fontSize:14,
  },
  image_categories:{
    width:30,
    height:19,
  }
});
