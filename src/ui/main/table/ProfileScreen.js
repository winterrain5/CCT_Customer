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
  NativeModules,
  RefreshControl,
} from 'react-native';

import Swiper from 'react-native-swiper';

import CoverLayer from '../../../widget/xpop/CoverLayer';

import DeviceStorage from '../../../uitl/DeviceStorage';

import DateUtil from '../../../uitl/DateUtil';

import WebserviceUtil from '../../../uitl/WebserviceUtil';

import StringUtils from '../../../uitl/StringUtils';

import {Card} from 'react-native-shadow-cards';

import QueueView from '../../../widget/QueueView';


let {width, height} = Dimensions.get('window');
let nativeBridge = NativeModules.NativeBridge;

export default class ProfileScreen extends Component {


  constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       userBean:undefined,
       card_amount:0.00,
       isRefreshing:false,
    }
  }




  UNSAFE_componentWillMount(){

    DeviceStorage.get('head_company_id').then((ompany_id) => {


      if (ompany_id) {
        this.setState({
            head_company_id: ompany_id,
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


      this.getNewReCardAmountByClientId(user_bean);

    });  
  }


  //注册通知
  componentDidMount(){

      var temporary = this;
      this.emit =  DeviceEventEmitter.addListener('user_update',(params)=>{
            //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI
           if (params) {
              temporary.setState({
                userBean: JSON.parse(params,'utf-8'),
               });
           }  
           
       });

      this.emit1 =  DeviceEventEmitter.addListener('user_money_up',(params)=>{
              //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI


              temporary.getTClientPartInfo(temporary.state.userBean.id);

              temporary.getNewReCardAmountByClientId(temporary.state.userBean);
             
             
      });



  }

  componentWillUnmount(){

      this.emit.remove();
      this.emit1.remove();

  }

    
  getNewReCardAmountByClientId(userBean){

    if (!userBean) {
      return
    }
    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getNewReCardAmountByClientId id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<clientId i:type="d:string">'+ userBean.id +'</clientId></n0:getNewReCardAmountByClientId></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('voucher','getNewReCardAmountByClientIdResponse',data, function(json) {

    
        if (json && json.success == 1) {


           temporary.setState({
              card_amount:StringUtils.toDecimal(json.data), 
           });
        }

    });      



  }


  _onRefresh(type){


      this.setState({
        isRefreshing:true,
    
      });

      this.getTClientPartInfo(this.state.userBean.id,true);

      this.getNewReCardAmountByClientId(this.state.userBean);

  

  }


  getTClientPartInfo(client_id,type){


      if (client_id == undefined) {
        return;
      }

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getTClientPartInfo id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<clientId i:type="d:string">'+ client_id+'</clientId>'+
    '</n0:getTClientPartInfo></v:Body></v:Envelope>';
    var temporary = this;

    WebserviceUtil.getQueryDataResponse('client','getTClientPartInfoResponse',data, function(json) {

        if (json && json.success == 1 && json.data ) {

            temporary.setState({
              userBean:json.data,
              isRefreshing:false,
            });


            if (type == true) {
                DeviceStorage.save('UserBean',json.data);
                DeviceEventEmitter.emit('user_update_home',JSON.stringify(json.data));
            } 
        }

    });

  }




  clickOpenMenu(){

    DeviceEventEmitter.emit('openMenu','ok');

  }


  clickItem(){


  }

  clickWallet(type){
    const { navigation } = this.props;
   
    if (navigation) {
      navigation.navigate('MyWalletActivity',{
        'page': type
      });
    }
    // nativeBridge.openNativeVc("MyWalletController",null);

  }

  clickReferFriend(){

    nativeBridge.openNativeVc("ReferFriendController",null);

  }

  clickContactUs(){

    nativeBridge.openNativeVc("ContactUsViewController",null);

  }

  clickOrders(){

    nativeBridge.openNativeVc("MyOrdersController",null);

  }

  clickQuestions(){

    nativeBridge.openNativeVc("QuestionHelperController",null);

  }


  clickLogout(){

    DeviceEventEmitter.emit('Logout','ok');
  }

  clickSetting(){

    nativeBridge.openNativeVc("SettingViewController",null);
    

  }

  clickAccountManagement(){

    nativeBridge.openNativeVc("AccountManagementController",null);


  }

  clickEditUser(){

    nativeBridge.openNativeVc("EditProfileViewController",null);


  }



  render() {

    var card_leve = require('../../../../images/car_lv_4.png');
    var level_name = 'Basic';

    if (this.state.userBean) {

      if (this.state.userBean.new_recharge_card_level) {

          if (this.state.userBean.new_recharge_card_level == '1') {

              card_leve = require('../../../../images/car_lv_4.png');
              level_name = 'Basic';

          }else if (this.state.userBean.new_recharge_card_level == '2') {

            card_leve = require('../../../../images/car_lv_1.png');
            level_name = 'Silver';

          }else if (this.state.userBean.new_recharge_card_level == '3') {

            card_leve = require('../../../../images/car_lv_3.png');
            level_name = 'Gold';

            
          }else if (this.state.userBean.new_recharge_card_level == '4') {

            card_leve = require('../../../../images/car_lv_2.png');
            level_name = 'Platinum';
            
          }

      }

    }

      return(
          <View style = {styles.bg}>

            <StatusBar barStyle="light-content" backgroundColor='#FFFFFF' translucent={false} />

            <SafeAreaView style = {styles.afearea} />


            <View style = {styles.view_head}>

               <TouchableOpacity 
                  activeOpacity = {0.8}
                  onPress={this.clickOpenMenu.bind(this)}>

                    <Image style = {styles.image_home} 
                      resizeMode = 'contain' 
                      source={require('../../../../images/home_user.png')}/> 

                </TouchableOpacity> 

                <Text style = {styles.text_title}>Profile</Text> 


                <View style = {styles.image_home} />     

            </View> 



             <View style = {styles.view_content}>


                <ScrollView 
                    style = {styles.scrollview}
                     refreshControl={
                        <RefreshControl
                            refreshing={this.state.isRefreshing}
                            onRefresh={this._onRefresh.bind(this, 0)}
                        />
                    }
                    showsVerticalScrollIndicator = {false}
                    contentOffset={{x: 0, y: 0}}
                    onScroll={this.changeScroll}>


                   <TouchableOpacity 
                        style = {{width:'100%'}}
                        activeOpacity = {0.8}
                        onPress={this.clickWallet.bind(this,1)}>   

                    <View style = {{width:'100%',padding:24}}>

                         <View style = {styles.view_user_card} >

                        <Image style = {styles.view_user_card} source={card_leve}/>



                        <View style = {styles.view_user_info}>


                          <View style = {styles.view_leve}>


                              <View style = {styles.view_name_leve}>

                                <Text style = {styles.text_leve}>{level_name}</Text>

                                <Text style = {styles.text_name}>{this.state.userBean ? (this.state.userBean.first_name + ' ' + this.state.userBean.last_name) : ''}</Text>


                              </View>



                            <TouchableOpacity 
                              activeOpacity = {0.8}
                              onPress={this.clickEditUser.bind(this)}> 


                              <Image style = {styles.image_edit} 
                                resizeMode = 'contain' 
                                source={require('../../../../images/edit0728.png')}/> 
  


                            </TouchableOpacity>  

                              

                          </View>


                         <View style = {{flex:1}}/>
                         


                         <View style = {styles.view_point}>



                            <View style = {[styles.view_circle,{marginLeft:16}]}>

                              <Image style = {[styles.image_icon]} 
                                resizeMode = 'contain' 
                                source={require('../../../../images/tongming_logo.png')}/> 

                            </View>

                            

                             <Text style = {[styles.text_name,{fontSize:16,marginLeft:8}]}>{'$' + this.state.card_amount}</Text>   



                             <View style = {[styles.view_circle,{marginLeft:10}]}>

                              <Image style = {[styles.image_icon]} 
                                resizeMode = 'contain' 
                                source={require('../../../../images/oyaltypointxxxhdpi.png')}/> 

                            </View>


                        
                             <Text style = {[styles.text_name,{fontSize:16,marginLeft:8}]} >{this.state.userBean ? (this.state.userBean.points ? (parseInt(this.state.userBean.points)) : '0') : '0'}</Text>    

                             <Text style = {[styles.text_name,{fontSize:16,fontWeight:'normal',marginLeft:5}]}>Points</Text>    



                         </View>   

                        </View>

                    </View>  


                    </View>


                   </TouchableOpacity>    


                      <Text style = {[styles.text_leve,{color:'#828282',marginLeft:24}]}>References</Text>



                      <TouchableOpacity 
                        activeOpacity = {0.8}
                        onPress={this.clickWallet.bind(this,0)}>

                         <View style = {styles.view_item}>


                            <Image style = {[styles.image_item]} 
                              resizeMode = 'contain' 
                              source={require('../../../../images/my_wallet.png')}/> 


                            <Text style = {styles.text_item}>My Wallet</Text>  

                     

                        </View> 


                      </TouchableOpacity>  



                       <TouchableOpacity 
                        activeOpacity = {0.8}
                        onPress={this.clickWallet.bind(this,1)}>

                         <View style = {styles.view_item}>

                            <Image style = {[styles.image_item]} 
                              resizeMode = 'contain' 
                              source={require('../../../../images/history.png')}/> 

                            <Text style = {styles.text_item}>Transaction History</Text>                 

                        </View> 


                      </TouchableOpacity>  


                      <TouchableOpacity 
                        activeOpacity = {0.8}
                        onPress={this.clickOrders.bind(this)}>

                         <View style = {styles.view_item}>

                            <Image style = {[styles.image_item]} 
                              resizeMode = 'contain' 
                              source={require('../../../../images/orders.png')}/> 

                            <Text style = {styles.text_item}>My Orders</Text>                 

                        </View> 


                      </TouchableOpacity>  


                      <TouchableOpacity 
                        activeOpacity = {0.8}
                        onPress={this.clickReferFriend.bind(this)}>

                         <View style = {styles.view_item}>

                            <Image style = {[styles.image_item]} 
                              resizeMode = 'contain' 
                              source={require('../../../../images/friend.png')}/> 

                            <Text style = {styles.text_item}>Refer to a Friend</Text>                 

                        </View> 


                      </TouchableOpacity>  


                    
                     <Text style = {[styles.text_leve,{color:'#828282',marginLeft:24,marginTop:20}]}>Account & Support</Text>




                     <TouchableOpacity 
                        activeOpacity = {0.8}
                        onPress={this.clickAccountManagement.bind(this)}>

                         <View style = {styles.view_item}>

                            <Image style = {[styles.image_item]} 
                              resizeMode = 'contain' 
                              source={require('../../../../images/account.png')}/> 

                            <Text style = {styles.text_item}>Account Management</Text>                 

                        </View> 


                      </TouchableOpacity>



                       <TouchableOpacity 
                        activeOpacity = {0.8}
                        onPress={this.clickContactUs.bind(this)}>

                         <View style = {styles.view_item}>

                            <Image style = {[styles.image_item]} 
                              resizeMode = 'contain' 
                              source={require('../../../../images/contact_us.png')}/> 

                            <Text style = {styles.text_item}>Contact Us</Text>                 

                        </View> 


                      </TouchableOpacity>




                       <TouchableOpacity 
                        activeOpacity = {0.8}
                        onPress={this.clickSetting.bind(this)}>

                         <View style = {styles.view_item}>

                            <Image style = {[styles.image_item]} 
                              resizeMode = 'contain' 
                              source={require('../../../../images/settings.png')}/> 

                            <Text style = {styles.text_item}>Settings</Text>                 

                        </View> 


                      </TouchableOpacity>




                       <TouchableOpacity 
                        activeOpacity = {0.8}
                        onPress={this.clickQuestions.bind(this)}>

                         <View style = {styles.view_item}>

                            <Image style = {[styles.image_item]} 
                              resizeMode = 'contain' 
                              source={require('../../../../images/questions.png')}/> 

                            <Text style = {styles.text_item}>Frequently Asked Questions</Text>                 

                        </View> 


                      </TouchableOpacity>




                       <TouchableOpacity 
                        style = {{marginTop:8}}
                        activeOpacity = {0.8}
                        onPress={this.clickLogout.bind(this)}>

                         <View style = {styles.view_item}>

                            <Image style = {[styles.image_item]} 
                              resizeMode = 'contain' 
                              source={require('../../../../images/logout.png')}/> 

                            <Text style = {[styles.text_item,{color:'#C44729'}]}>Logout</Text>                 

                        </View> 


                      </TouchableOpacity>


                
                    

                  
                </ScrollView>    






             </View>

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
    flex:0,
    backgroundColor:'#145A7C'
  },
  afearea_foot:{
    flex:0,
    backgroundColor:'#FFFFFF'
  },
  view_head:{
    padding:19,
    width: '100%',
    backgroundColor:'#145A7C',
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  image_home :{
    width:18,
    height:18
  },
  text_title :{
    color:'#FFFFFF',
    fontSize: 16,
    fontWeight: 'bold',
  },
   scrollview:{
    flex:1,
    backgroundColor:'#FFFFFF'
  },
  view_value : {
    paddingTop:8,
    paddingLeft:16,
    paddingBottom:16,
    paddingRight:16,
    backgroundColor:'#145A7C',
  },
  view_content:{
    flex:1,
  },
  view_user_card:{
    borderRadius:16,
    width:'100%',
    height:124,
  },
  view_user_info:{
    width:'100%',
    height:'100%',
    position:'absolute',
  },
  view_leve:{
    padding:16,
    width:'100%',
    flexDirection: 'row',
    alignItems: 'center'
  },
  view_name_leve:{
    flex:1,
  },
  text_leve:{
    fontSize:12,
    color:'#333'
  },
  text_name:{
    fontSize:18,
    fontWeight:'bold',
    color:'#333',
  },
  image_edit:{
    width:24,
    height:24,
  },
  view_point:{
    borderBottomLeftRadius:16,
    borderBottomRightRadius:16,
    width:'100%',
    height:56,
    backgroundColor:'#0D333333',
    flexDirection: 'row',
    alignItems: 'center'
  },
  view_circle:{
    backgroundColor:'#FFFFFF',
    borderRadius:50,
    width:25,
    height:25,
    justifyContent: 'center',
    alignItems: 'center',
  },
  image_icon:{
    width:15,
    height:15,
  },
  view_item:{
    marginLeft:24,
    marginRight:24,
    width:'100%',
    flexDirection: 'row',
    paddingBottom:8,
    paddingTop:8,
    alignItems: 'center',
  },
  image_item:{
    width:40,
    height:40,
  },
  text_item:{
    marginLeft:8,
    fontSize:16,
    color:'#000000'
  }
});