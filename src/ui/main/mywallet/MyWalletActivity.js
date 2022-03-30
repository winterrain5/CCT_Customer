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


import {CommonActions,useNavigation} from '@react-navigation/native';


let {width, height} = Dimensions.get('window');


import WalletRewardsTable from '../table/WalletRewardsTable';

import WalletTransactionsTable from '../table/WalletTransactionsTable';

import ScrollableTabView, {ScrollableTabBar, DefaultTabBar} from 'react-native-scrollable-tab-view';



export default class MyWalletActivity extends Component {

   constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       userBean:undefined,
       card_amount:'0.00',
       progress:0,
       page:0,
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

      this.getNewReCardAmountByClientId(user_bean);

    });

    if (this.props.route.params) {

      this.setState({
        page:this.props.route.params.page,
      });
    }



  }


    //注册通知
  componentDidMount(){

     var temporary = this;

    this.emit =  DeviceEventEmitter.addListener('transactions_detail',(params)=>{
          //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI
          temporary.toTransactionsDetailActivity(params);
     });


     this.emit1 =  DeviceEventEmitter.addListener('vaoucher_detail',(params)=>{
          //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI
          var voucher ;

           if (params) {
               voucher = JSON.parse(params,'utf-8');
           }

           if (voucher) {
              temporary.toVoucherDetailActivity(voucher);
           }
     });

      this.emit2 =  DeviceEventEmitter.addListener('user_money_up',(params)=>{
              //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI


              temporary.getTClientPartInfo(temporary.state.userBean.id);

              temporary.getNewReCardAmountByClientId(temporary.state.userBean);
             
             
      });



  }

  componentWillUnmount(){

    this.emit.remove();
    this.emit1.remove();
    this.emit2.remove();

  }


  toVoucherDetailActivity(voucher){

    const { navigation } = this.props;
   
    if (navigation) {
      navigation.navigate('VoucherDetailActivity',{
        'vaoucher_detail':voucher,
      });
    }
    
  }



  toTransactionsDetailActivity(order_id){


    const { navigation } = this.props;
   
    if (navigation) {
      navigation.navigate('TransactionsDetailActivity',{
        'order_id':order_id,
      });
    }


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

  clickTopUp(){

    const { navigation } = this.props;
   
    if (navigation) {
      navigation.navigate('TopUpActivity');
    }

  }


  clicktoCardDetailsActivity(){

    const { navigation } = this.props;
   
    if (navigation) {
      navigation.navigate('CardDetailsActivity');
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

            
          }

      

    }


      return(

         <View style = {styles.bg}>

            <StatusBar barStyle="light-content" backgroundColor='#FFFFFF' translucent={false} />

             <SafeAreaView style = {styles.afearea} >

                 <TitleBar
                    title = {'My Wallet'} 
                    navigation={navigation}
                    hideLeftArrow = {true}
                    hideRightArrow = {false}
                    extraData={this.state}/>

                 <View style = {styles.view_content}> 

                    <View 
                        style = {styles.scrollview}
                        stickyHeaderIndices={[2]}
                        showsVerticalScrollIndicator = {false}
                        contentOffset={{x: 0, y: 0}}
                        onScroll={this.changeScroll}>


                        <TouchableOpacity 
                          activeOpacity = {0.8 }
                          onPress={this.clicktoCardDetailsActivity.bind(this)}>


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


                       </TouchableOpacity> 



                        <View style = {styles.view_points}>

                            <Text style = {styles.text_points}>Loyalty Points</Text>



                            <View style = {{width:'100%', flexDirection: 'row',marginTop:8}}>


                                <Text style = {styles.text_leve}>{(this.state.userBean && this.state.userBean.points) ? parseInt(this.state.userBean.points) : '0'}</Text>


                                <Text style = {[styles.text_points,{marginTop:5,marginLeft:8}]}>Points</Text>


                            </View>

                        </View>



                          <ScrollableTabView
                            initialPage = {this.state.page}
                            tabBarUnderlineStyle={{backgroundColor:'#C44729',height:2}}
                            tabBarActiveTextColor='#C44729'
                            tabBarInactiveTextColor='#000000'>


                            <WalletRewardsTable tabLabel="Rewards" />

                            <WalletTransactionsTable tabLabel="Transactions" />



                          </ScrollableTabView>
                    
                      
                    </View>   
                        
               

                 </View>  





             </SafeAreaView>



             <SafeAreaView style = {styles.afearea_foot} />


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
  }
});

