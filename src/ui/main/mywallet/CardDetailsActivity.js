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
  Dimensions
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

import {Card} from 'react-native-shadow-cards';


export default class CardDetailsActivity extends Component {

  constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       userBean:undefined,
       card_amount:'0.00',
       card_discounts:[],
       card_friends:[],
       card_owners:[],
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

      //获取卡的金额
      this.getNewReCardAmountByClientId(user_bean);

      //会员折扣信息
      // this.getNewCardDiscountsByLevel(user_bean);
      this.getCardDiscountDetails(user_bean);

      //谁绑了我的卡
      this.getCardFriends(user_bean);


      //我绑了谁的卡，可以进行支付
      this.getFriendsCard(user_bean);


    });

  }


   //注册通知
  componentDidMount(){


    var temporary = this;
      
    this.emit =  DeviceEventEmitter.addListener('user_card',(params)=>{
          //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI
       
        //谁绑了我的卡
      temporary.getCardFriends(temporary.state.userBean);


       temporary.getFriendsCard(temporary.state.userBean);


     });


    this.emit2 =  DeviceEventEmitter.addListener('user_money_up',(params)=>{
              //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI


              temporary.getTClientPartInfo(temporary.state.userBean.id);

              temporary.getNewReCardAmountByClientId(temporary.state.userBean);
             
             
      });


  }

  componentWillUnmount(){

    this.emit.remove();
    this.emit2.remove();

  }



  getFriendsCard(userBean){


    if (!userBean) {
      return;
    }

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
    '<v:Header />'+
    '<v:Body><n0:getFriendsCard id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<clientId i:type="d:string">'+ userBean.id +'</clientId>'+
    '</n0:getFriendsCard></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('voucher','getFriendsCardResponse',data, function(json) {

        if (json && json.success == 1 && json.data) {
           temporary.setState({
              card_owners:json.data, 
           });
        }

    });      


  }


   getTClientPartInfo(client_id){

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
            });

            DeviceStorage.save('UserBean',json.data);
        }

    });

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

  getNewCardDiscountsByLevel(userBean){

    if (!userBean) {
      return
    }
    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body>'+
    '<n0:getNewCardDiscountsByLevel id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<companyId i:type="d:string">'+ this.state.head_company_id +'</companyId>'+
    '<cardLevel i:type="d:string">'+ userBean.new_recharge_card_level +'</cardLevel>'+
    '</n0:getNewCardDiscountsByLevel></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('vip-definition','getNewCardDiscountsByLevelResponse',data, function(json) {

        if (json && json.success == 1) {
           temporary.setState({
              card_discounts:json.data, 
           });
        }

    });      

  }


  getCardDiscountDetails(userBean){

    if (!userBean) {
      return;
    }

    var levelId = userBean.new_recharge_card_level;

    if (userBean.new_recharge_card_level == undefined || userBean.new_recharge_card_level == '0') {
      levelId = '1';
    }


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
    '<v:Header />'+
    '<v:Body><n0:getCardDiscountDetails id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<levelId i:type="d:string">'+ levelId +'</levelId>'+
    '</n0:getCardDiscountDetails></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('card-discount-content','getCardDiscountDetailsResponse',data, function(json) {

        if (json && json.success == 1) {
           temporary.setState({
              card_discounts:json.data, 
           });
        }

    });      

  }

  getCardFriends(userBean){

     if (!userBean) {
      return
    }
    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body>'+
    '<n0:getCardFriends id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<ownerId i:type="d:string">'+ userBean.id+'</ownerId>'+
    '</n0:getCardFriends></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('voucher','getCardFriendsResponse',data, function(json) {

        if (json && json.success == 1) {
           temporary.setState({
              card_friends:json.data 
           });
        }

    });      

  }



  clickTopUp(){

    const { navigation } = this.props;
   
    if (navigation) {
      navigation.navigate('TopUpActivity');
    }

  }


  _yourPrivilegesView(){


    if (this.state.card_discounts ) {

    

      var discounts = [];


      if (this.state.card_discounts.r_discount1 != undefined && this.state.card_discounts.r_discount1.length > 0) {

          discounts.push(

            <View style = {[styles.view_discount_item,{marginTop:5}]}>

                <Text style = {styles.text_discount_item}>·</Text>

                <Text style = {styles.text_discount_item}>{this.state.card_discounts.r_discount1}</Text>


            </View>

          );
      }


      if (this.state.card_discounts.r_discount2!= undefined && this.state.card_discounts.r_discount2.length > 0) {

          discounts.push(

            <View style = {[styles.view_discount_item,{marginTop: 5}]}>

                <Text style = {styles.text_discount_item}>·</Text>

                <Text style = {styles.text_discount_item}>{this.state.card_discounts.r_discount2}</Text>


            </View>

          );
      }



      if (this.state.card_discounts.r_discount3 != undefined && this.state.card_discounts.r_discount3.length > 0) {

          discounts.push(

            <View style = {[styles.view_discount_item,{marginTop: 5}]}>

                <Text style = {styles.text_discount_item}>·</Text>

                <Text style = {styles.text_discount_item}>{this.state.card_discounts.r_discount3}</Text>


            </View>

          );
      }


      return discounts;



    }else {


        return (<View />);


    }


  }


  _cardOwnerView(){

    if (this.state.card_owners && this.state.card_owners.length > 0) {


       var owner_views = [];

       for (var i = 0; i < this.state.card_owners.length; i++) {

           var owner =  this.state.card_owners[i];

           owner_views.push(

            <View style = {[styles.view_friend_item,{marginTop:i == 0 ? 16 : 5}]}>


              <View style = {{flex:1}}>

                  <Text style = {[styles.text_discount_item,{fontWeight:'bold'}]}>{owner.first_name + ' ' +  owner.last_name}</Text>

                  <Text style = {styles.text_discount_item}>{owner.mobile}</Text>

              </View>

            
              <TouchableOpacity 
                activeOpacity = {0.8 }
                onPress={this.deleteFriend.bind(this,owner)}>

                 <Text style = {styles.text_view_all}>Remove</Text>

              </TouchableOpacity>  
             
            </View>

            );
       }


       return (

          <View style = {styles.view_tiers}>

              <View style = {styles.view_name_volue}>

                  <Text style = {styles.text_tiers_name}>Card Owner</Text>
            
              </View>


              {owner_views}
             

           </View>
      );

    }else {


      return (

          
          <View />

      );


    }


  }



  _cardUsersView(){


    if (this.state.card_friends && this.state.card_friends.length > 0) {


      var friend_views = [];

      for (var i = 0; i < this.state.card_friends.length; i++) {
        var friend = this.state.card_friends[i];

        friend_views.push(

          <View style = {[styles.view_friend_item,{marginTop:i == 0 ? 16 : 5}]}>


            <TouchableOpacity
                style = {{flex:1}}
                activeOpacity = {0.8 }
                onPress={this.clickFriendCard.bind(this,friend)}>



                <View style = {{with:'100%',flexDirection: 'row',alignItems: 'center'}}>


                  <View style = {{flex:1}}>

                      <Text style = {[styles.text_discount_item,{fontWeight:'bold'}]}>{friend.first_name + ' ' +  friend.last_name}</Text>

                      <Text style = {styles.text_discount_item}>{friend.mobile}</Text>

                  </View>


                  <Image style = {{width:8,height:13}} 
                       resizeMode = 'contain' 
                       source={require('../../../../images/you.png')}/> 


                </View>

                
             </TouchableOpacity>     


              
          

          </View>

        );


      }


      return friend_views;



    }else {


        return ( 

          <View style = {[styles.view_friend_item,{marginTop:16}]}>


            <Text style = {styles.text_discount_item}>You have not shared your card with your loved ones</Text>


          </View>

        );
    }

  }


  clickFriendCard(friend){


    const { navigation } = this.props;
   
    if (navigation) {
      navigation.navigate('UserCardDetailsActivity',{'friend':friend});
    }




  }



  deleteFriend(friend){

          // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                          <Text style = {[styles.text_popup_title]}>Are you sure want to remove this user?</Text>


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
                               onPress={this.deleteCardFriend.bind(this,friend)}>

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


  deleteCardFriend(friend){

    this.coverLayer.hide();

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
    '<v:Header />'+
    '<v:Body><n0:deleteCardFriend id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<id i:type="d:string">'+ friend.id + '</id>'+
    '<logData i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
    '<item><key i:type="d:string">ip</key><value i:type="d:string"></value></item>'+
    '<item><key i:type="d:string">create_uid</key><value i:type="d:string">'+ this.state.userBean.user_id +'</value></item>'+
    '</logData></n0:deleteCardFriend></v:Body></v:Envelope>';

    var temporary = this;
    Loading.show();
    WebserviceUtil.getQueryDataResponse('voucher','deleteCardFriendResponse',data, function(json) {

        
        if (json && json.success == 1) {

          temporary.deleteUserFromWallet(friend.card_owner_id);
        
        }else {
          Loading.hidden();
          toastShort('Removed Failed');
        }

    });      


  }



   deleteUserFromWallet(friend_id){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
    '<v:Header />'+
    '<v:Body><n0:deleteUserFromWallet id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<friendId i:type="d:string">'+ friend_id +'</friendId>'+
    '<clientId i:type="d:string">'+ this.state.userBean.id +'</clientId>'+
    '</n0:deleteUserFromWallet></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('notifications','deleteUserFromWalletResponse',data, function(json) {

        Loading.hidden();
        toastShort('Removed Successfully');
      
        //更新界面

      //我绑了谁的卡，可以进行支付
      temporary.getFriendsCard(temporary.state.userBean);


    });      



  }







  clickTermsAndConditions(){

         // 根据传入的方法渲染并弹出

    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                          <Text style = {styles.text_popup_title}>Terms & conditions</Text>


                          <Text style = {[styles.text_popup_terms_content,{marginTop:32}]}>For purchase of treatment using CCT Wallet, member will receive FOC consultation with physician.</Text>


                          <Text style = {[styles.text_popup_terms_content]}>Redemption of sessions are based on ala carte pricing.</Text>


                          <Text style = {[styles.text_popup_terms_content]}>Credits can be used for Chien Chi Tow / Madam Partum label products, pills and medication.</Text>


                          <Text style = {[styles.text_popup_terms_content]}>Credit value is inclusive of GST amount</Text>

                          
                          <Text style = {[styles.text_popup_terms_content]}>Bonus value cannot be used for GST or tax declaration.</Text>

                          <Text style = {[styles.text_popup_terms_content]}>Privilege tiers are tagged to current wallet.</Text>


                          <Text style = {[styles.text_popup_terms_content]}>Credits are valid for 1 year from the date of purchase.</Text>


                          <Text style = {[styles.text_popup_terms_content]}>Customer can hold 1 CCT Wallet at any one time</Text>


                          <Text style = {[styles.text_popup_terms_content,{marginBottom:32}]}>Chien Chi Tow will not be held responsible for the misuse of credits due to 1) loss of device, 2) utilisation of credits by nominated user. Members should report to Chien Chi Tow immediately to suspend account from further misuse.</Text>


                                   
              
                        </View>
                    )
                },
            ()=>this.coverLayer.hide(),
            CoverLayer.popupMode.bottom);

  }


  clickAddUsers(){

    const { navigation } = this.props;
   
    if (navigation) {
      navigation.navigate('AddCardUserActivity');
    }

  }

  clickViewTiers(){

    const { navigation } = this.props;
   
    if (navigation) {
      navigation.navigate('TierPrivilegesActivity');
    }


  }






  render() {

    const { navigation } = this.props;


    var card_leve = require('../../../../images/car_lv_4.png');
    var level_name = 'Basic';
    var level_hint = '';
    var progress = 0;


    var active_amount = 0.00;   // 当前阶段的钱
    var keep = 0.00; // 保级金额
    var upgrade = 0.00; //  下一级金额



    if (this.state.userBean) {


         try{
            active_amount = parseFloat(this.state.userBean.active_amount);
          }catch(e){

          }

          try{
            keep = parseFloat(this.state.userBean.keep);
          }catch(e){

          }

          try{
            upgrade = parseFloat(this.state.userBean.upgrade);
          }catch(e){

          } 


    
          if (this.state.userBean.new_recharge_card_level == undefined || this.state.userBean.new_recharge_card_level == '1') {


              card_leve = require('../../../../images/car_lv_4.png');
              level_name = 'Basic';


              if (this.state.userBean.first_recharge_card_status == '0') {
                // 第一次购买
                level_hint = 'When you buy a recharge card for the first time, you can enjoy benefits. Recharge 500 to upgrade silver card, recharge 1000 to gold card and recharge $2000 to platinum card';
              
                progress = 0 ;


              }else {


                level_hint = 'You are $'  + upgrade + 'away from getting upgraded to  Silver Tier for greater benefits.'

                progress = active_amount / 200;



                  // var item_tax = 1000 - parseFloat(this.state.userBean.consumption);

                  // if (item_tax >= 0) {

                  //     progress = 1- item_tax / 1000;

                  //     level_hint = 'You are $'  + item_tax + 'away from getting upgraded to  Silver Tier for greater benefits.'

                  // }else {

                  //     progress = 1;

                  //     level_hint = 'You are $'  + 0 + 'away from getting upgraded to  Silver Tier for greater benefits.'

                  // }

                


              }




          }else if (this.state.userBean.new_recharge_card_level == '2') {

            card_leve = require('../../../../images/car_lv_1.png');
            level_name = 'Silver';


            level_hint = 'You are $'  + upgrade + 'away from getting upgraded to  Gold Tier for greater benefits.'

            progress = active_amount / 300;


            //  var item_tax = 2000 - parseFloat(this.state.userBean.consumption);

            // if (item_tax >= 0) {

            //     progress = 1-  item_tax / 1000;

            //     level_hint = 'You are $'  + item_tax + 'away from getting upgraded to  Gold Tier for greater benefits.'

            // }else {

            //     progress = 1;

            //     level_hint = 'You are $'  + 0 + 'away from getting upgraded to  Gold Tier for greater benefits.'

            // }





          }else if (this.state.userBean.new_recharge_card_level == '3') {

            card_leve = require('../../../../images/car_lv_3.png');
            level_name = 'Gold';


            level_hint = 'You are $'  + upgrade + 'away from getting upgraded to  Platinum Tier for greater benefits.'

            progress = active_amount / 500;



            //  var item_tax = 4000 - parseFloat(this.state.userBean.consumption);

            // if (item_tax >= 0) {

            //     progress = 1-  item_tax / 2000;

            //     level_hint = 'You are $'  + item_tax + 'away from getting upgraded to  Platinum Tier for greater benefits.'

            // }else {

            //     progress = 1;

            //     level_hint = 'You are $'  + 0 + 'away from getting upgraded to  Platinum Tier for greater benefits.'

            // }


            
          }else if (this.state.userBean.new_recharge_card_level == '4') {

            card_leve = require('../../../../images/car_lv_2.png');
            level_name = 'Platinum';


            progress = active_amount / 1000;

            level_hint = 'Spend or Top $' + keep + ' more to maintain Platinum Tier';

            // progress = 1;
            // level_hint = '';


            
          }

      

    }

    return(

      <View style = {styles.bg}>

        <StatusBar barStyle="light-content" backgroundColor='#FFFFFF' translucent={false} />

        <SafeAreaView style = {styles.afearea} >

            <TitleBar
                title = {'Wallet Details'} 
                navigation={navigation}
                hideLeftArrow = {true}
                hideRightArrow = {false}
                extraData={this.state}/>


            <View style = {styles.view_content}> 

                <ScrollView 
                  style = {styles.scrollview}
                  showsVerticalScrollIndicator = {false}
                  contentOffset={{x: 0, y: 0}}
                  onScroll={this.changeScroll}>

                  <View style = {{width:'100%',padding:24}}>

                       <View style = {styles.view_user_card} >

                         <Image style = {styles.view_user_card} source={card_leve}/>

                       </View>


                      <View style = {styles.view_user_info}>


                          <View style = {styles.view_name_volue}>

                              <Text style = {styles.text_leve}>{level_name}</Text>


                              <View style ={{ flexDirection: 'row'}}>

                                  <Text style = {[styles.text_leve,{fontWeight:'normal'}]}>{this.state.card_amount}</Text>




                                    <TouchableOpacity 
                                        activeOpacity = {0.8 }
                                        onPress={this.clickTopUp.bind(this)}>


                                         <ImageBackground style = {styles.image_edit} 
                                            source={require('../../../../images/bian_hong.png')}>


                                            <Image style = {{width:10,height:10}} 
                                                  
                                                 source={require('../../../../images/bai_up.png')}/>     
                      
                                         </ImageBackground > 


                                    </TouchableOpacity>
                                        

                                  

                              </View>


                          </View> 



                          <View style = {{width:'100%',marginTop:8}}>


                            <ProgressBar
                              progress = {progress}

                             />


                          </View>


                          <View style = {{width:'100%',flexDirection: 'row'}}>


                              <Text style = {[styles.text_hint,{marginRight:2}]}>{level_hint}</Text>


                              <View  >

                                  <Text style = {styles.text_hint}>Expires</Text>


                                  <Text style = {[styles.text_leve,{fontSize:12}]}>{this.state.userBean ? DateUtil.getShowTimeFromDate4(this.state.userBean.new_recharge_card_period) : ''}</Text>

                              </View>

                          </View> 

                      </View>   
                      
                  </View>


                   <View style = {styles.view_line} />



                   <View style = {styles.view_tiers}>

                      <View style = {styles.view_name_volue}>

                          <Text style = {styles.text_tiers_name}>Your Privileges</Text>


                           <TouchableOpacity 
                                activeOpacity = {0.8 }
                                onPress={this.clickViewTiers.bind(this)}> 


                                 <Text style = {styles.text_view_all}>View Tiers</Text>


                           </TouchableOpacity>     


                         


                      </View>


                      {this._yourPrivilegesView()}  


                   </View>

                   <View style = {styles.view_line} />


                  <View style = {styles.view_tiers}>

                      <View style = {styles.view_name_volue}>

                          <Text style = {styles.text_tiers_name}>Card Users</Text>


                          <TouchableOpacity 
                                activeOpacity = {0.8 }
                                onPress={this.clickAddUsers.bind(this)}> 


                                  <Text style = {styles.text_view_all}>+ Add Users</Text>


                            </TouchableOpacity>   

                

                      </View>


                      {this._cardUsersView()}  


                   </View>


                  <View style = {styles.view_line} />



                   {this._cardOwnerView()}  



        

                  <View style = {styles.view_line} />

              

                  <View style = {styles.view_tiers}>



                     <TouchableOpacity 
                        activeOpacity = {0.8 }
                        onPress={this.clickTermsAndConditions.bind(this)}> 


                        <View style = {styles.view_name_volue}>

                          <Text style = {styles.text_tiers_name}>Terms and Conditions</Text>

                           <Image 
                              style = {{width:8,height:13}} 
                              resizeMode = 'contain' 
                              source={require('../../../../images/you.png')}/>     


                        </View>


                    </TouchableOpacity>    

                      


                   </View>




              </ScrollView>   

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
    flex:1,
    backgroundColor:'#FFFFFF'
  },
   scrollview:{
    flex:1,
    backgroundColor:'#FFFFFF'
  },
  view_user_card:{
    borderRadius:16,
    width:'100%',
    height:184,
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
    fontSize:18,
    fontWeight:'bold',
    color:'#333',
  },
  image_edit:{
    marginLeft:3,
    width:24,
    height:24,
    paddingBottom:3,
    paddingRight:1,
    justifyContent: 'center',
    alignItems: 'center'
  },
  view_user_info:{
    marginTop:24,
    marginLeft:24,
    padding:24,
    width:'100%',
    height:'100%',
    position:'absolute',
   
  },
  view_name_volue:{
    width:'100%',
    alignItems: 'center',
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  text_hint:{
    marginTop:8,
    flex:1,
    fontSize:12,
    color:'#828282'
  },
  view_points:{
    paddingLeft:24,
    paddingRight:24,
    width:'100%',
  },
  text_points:{
    fontSize:14,
    color:'#828282'
  },
  view_line:{
    width:'100%',
    height:1,
    backgroundColor:'#dbdbdd'
  },
  view_tiers:{
    width:'100%',
    padding:24,
  },
  text_tiers_name:{
    fontSize:18,
    color:'#145A7C',
    fontWeight:'bold',
  },
  text_view_all:{
    fontSize:14,
    color:'#C44729',
    fontWeight:'bold',
  },
  view_discount_item:{
    marginTop:16,
    width:'100%',
    flexDirection: 'row',
  },
  text_discount_item:{
    fontSize:14,
    color:'#333333',
  },
  view_friend_item:{
    alignItems: 'center',
    width:'100%',
    flexDirection: 'row',
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
    fontSize:16,
    textAlign :'center',
    fontWeight: 'bold',
  },
  text_popup_content:{
    width:'100%',
    marginTop:32,
    fontSize:16,
    color:'#333333',
    textAlign :'center',
  },
   view_popup_next:{
      marginTop:33,
      width:'100%',
      marginBottom:30,
  },
  text_popup_terms_content:{
    width:'100%',
    marginTop:16,
    fontSize:16,
    color:'#333333',

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
    marginTop:31,
    width:'100%',
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom:74,
  },
  xpop_touch:{
     width:'48%',

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

});


