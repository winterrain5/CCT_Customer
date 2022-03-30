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

export default class UserCardDetailsActivity extends Component {

  constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       userBean:undefined,
       card_friend:undefined,
       transaction_datas:undefined,
       text_input:undefined,
       intput_amount:undefined,
       selected_limint_type: 0, // 0 无限， 有限制
       selected_amount_type:'300',
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


    if (this.props &&  this.props.route && this.props.route.params) {


        var friend = this.props.route.params.friend;

        this.setState({
          card_friend:friend,

        });


        this.getSalesByFriendUsedCard(friend.friend_id);


    }



  }


  getSalesByFriendUsedCard(friend_id){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
    '<v:Header />'+
    '<v:Body><n0:getSalesByFriendUsedCard id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<friendId i:type="d:string">'+ friend_id +'</friendId>'+
    '<length i:type="d:string">500</length>'+
    '<start i:type="d:string">0</start>'+
    '</n0:getSalesByFriendUsedCard></v:Body></v:Envelope>';



    var temporary = this;
    WebserviceUtil.getQueryDataResponse('sales-report','getSalesByFriendUsedCardResponse',data, function(json) {

        if (json && json.success == 1 && json.data) {
           temporary.setState({
              transaction_datas:json.data, 
           });
        }

    });      



  }


  _transactionsItemsView(){


    if (this.state.transaction_datas) {

      var date_items = [];

       for (var key in this.state.transaction_datas) {
            
            var tran_items = [];

            var id_product_obj = this.state.transaction_datas[key];

             for (var id_key in id_product_obj) {

              var items = id_product_obj[id_key];

              if (items && items.length > 0) {

                for (var i = 0; i < items.length; i++) {

                     var item =  items[i];


                     var total = 0;
                     var paid_amount = 0;
                     var freight = 0;

                     try{
                        paid_amount = parseFloat(item.paid_amount);
                     }catch(e){

                     }

                     try{
                        freight = parseFloat(item.freight);
                     }catch(e){

                     }

                     total = paid_amount + freight;



                     tran_items.push(


                      <View style = {{width:'100%'}}>


                         <View style = {[styles.view_name_delete,{paddingLeft:24,paddingTop:16,paddingBottom:16}]}>


                            <Text style = {[styles.text_tran_item_name,{flex:1}]}>{item.name}</Text>

                            <Text style = {[styles.text_tran_item_name,{marginLeft:8,marginRight:24}]} >${StringUtils.toDecimal(total)}</Text>

                         </View>


                         <View  style = {styles.view_line}/>


                      </View>

            
                    );


                }

              }
             }


             date_items.push(

              <View style = {{width:'100%'}}>


                    <View style = {styles.view_tran_item_date}>


                      <Text style = {styles.text_tran_item_date}>{DateUtil.getShowTimeFromDate4(key)}</Text>


                    </View>


                    {tran_items}

              </View>


            );
      
        } 

        return date_items;


    }else {


      return (<View />);

    }

  }


  clickDeleteUser(){


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
                               onPress={this.deleteCardFriend.bind(this)}>

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


  deleteCardFriend(){


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
    '<v:Header />'+
    '<v:Body><n0:deleteCardFriend id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<id i:type="d:string">'+ this.state.card_friend.id + '</id>'+
    '<logData i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
    '<item><key i:type="d:string">ip</key><value i:type="d:string"></value></item>'+
    '<item><key i:type="d:string">create_uid</key><value i:type="d:string">'+ this.state.userBean.user_id +'</value></item>'+
    '</logData></n0:deleteCardFriend></v:Body></v:Envelope>';

    var temporary = this;
    Loading.show();
    WebserviceUtil.getQueryDataResponse('voucher','deleteCardFriendResponse',data, function(json) {

        
        if (json && json.success == 1) {

          temporary.deleteUserFromWallet();
        
        }else {
          Loading.hidden();
          toastShort('Removed Failed');
        }

    });      


  }







  deleteUserFromWallet(){


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
    '<v:Header />'+
    '<v:Body><n0:deleteUserFromWallet id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<friendId i:type="d:string">'+ this.state.card_friend.friend_id +'</friendId>'+
    '<clientId i:type="d:string">'+ this.state.userBean.id +'</clientId>'+
    '</n0:deleteUserFromWallet></v:Body></v:Envelope>';

    var temporary = this;
    Loading.show();
    WebserviceUtil.getQueryDataResponse('notifications','deleteUserFromWalletResponse',data, function(json) {

        toastShort('Removed Successfully');
        DeviceEventEmitter.emit('user_card','ok');
        temporary.props.navigation.goBack();

    });      

  }

  clickTransactionLimit(){


    // 初始化
    this.setState({
       intput_amount:'$300.00',
       selected_limint_type: 0, // 0 无限， 有限制
       selected_amount_type:'300',

    });

         // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                          <Text style = {[styles.text_popup_title]}>Set Transaction Limit</Text>



                         <TouchableOpacity
                            style = {{width:'100%'}} 
                            onPress={this.clickLimitType.bind(this,0)}
                            activeOpacity = {0.8 }>


                            <View style = {styles.view_limit_item}>


                              <Image 
                                style = {{width:20,height:20}} 
                                resizeMode = 'contain' 
                                source={this.state.selected_limint_type == 0 ? require('../../../../images/quan_red_0225.png') : require('../../../../images/quan_0225.png')}/> 


                               <Text style = {styles.text_item_limit}>No Limit</Text>    


                            </View>
                            

                        </TouchableOpacity>    
   

                         <TouchableOpacity
                            style = {{width:'100%'}} 
                            onPress={this.clickLimitType.bind(this,1)}
                            activeOpacity = {0.8 }>



                            <View style = {[styles.view_limit_item]}>


                              <Image 
                                style = {{width:20,height:20}} 
                                resizeMode = 'contain' 
                                source={this.state.selected_limint_type == 1 ? require('../../../../images/quan_red_0225.png') : require('../../../../images/quan_0225.png')}/> 


                               <Text style = {styles.text_item_limit}>Limit Amount</Text>    


                             </View>


                        </TouchableOpacity>    


                                

                          <Text style = {styles.text_limit_hit}>Select the amount you want to limit user’s per transaction</Text>



                           <View style = {styles.view_edit}>


                             <TextInput 
                                style = {styles.text_input}
                                ref='intput_amount'
                                placeholder=''
                                multiline = {false}
                                textAlign = 'center'
                                value = {this.state.intput_amount} 
                                onChangeText={(text) => {
                                 
                                   this.onChangeText(text);
                                 
                                  }  
                                }/>

                          </View>



                          <View style = {styles.view_amount_list}>


                            <TouchableOpacity 
                                onPress={this.clickAmount.bind(this,'300')}
                                activeOpacity = {0.8 }>

                                 <View style = {[styles.view_amount_item,{backgroundColor: this.state.selected_amount_type == '300' ? '#145A7C' : '#F2F2F2'}]}>

                                    <Text style= {[styles.text_amount_item,{color:this.state.selected_amount_type == '300' ? '#FFFFFF' : '#333333'}]}>$300</Text>

                                </View>


                            </TouchableOpacity>  


                           

                             <TouchableOpacity 
                                onPress={this.clickAmount.bind(this,'500')}
                                activeOpacity = {0.8 }>

                                 <View style = {[styles.view_amount_item,{backgroundColor: this.state.selected_amount_type == '500' ? '#145A7C' : '#F2F2F2'}]}>

                                    <Text style= {[styles.text_amount_item,{color:this.state.selected_amount_type == '500' ? '#FFFFFF' : '#333333'}]}>$500</Text>

                                </View>


                            </TouchableOpacity> 



                            <TouchableOpacity 
                                onPress={this.clickAmount.bind(this,'700')}
                                activeOpacity = {0.8 }>

                                 <View style = {[styles.view_amount_item,{backgroundColor: this.state.selected_amount_type == '700' ? '#145A7C' : '#F2F2F2'}]}>

                                    <Text style= {[styles.text_amount_item,{color:this.state.selected_amount_type == '700' ? '#FFFFFF' : '#333333'}]}>$700</Text>

                                </View>


                            </TouchableOpacity>   


                             <TouchableOpacity 
                                onPress={this.clickAmount.bind(this,'1000')}
                                activeOpacity = {0.8 }>

                                 <View style = {[styles.view_amount_item,{backgroundColor: this.state.selected_amount_type == '1000' ? '#145A7C' : '#F2F2F2'}]}>

                                    <Text style= {[styles.text_amount_item,{color:this.state.selected_amount_type == '1000' ? '#FFFFFF' : '#333333'}]}>$1000</Text>

                                </View>


                            </TouchableOpacity> 

                          </View>



                           <View style = {styles.next_view}>

                            <TouchableOpacity style = {[styles.next_layout,{backgroundColor:'#C44729'}]}  
                                activeOpacity = {0.8}
                                onPress={this.clickLimitDone.bind(this)}>

                              <Text style = {styles.next_text}>Done</Text>

                            </TouchableOpacity>

                        </View>



                          
                        </View>
                    )
                },
            ()=>this.coverLayer.hide(),
            CoverLayer.popupMode.bottom);

  }


  clickLimitType(type){


    this.setState({
      selected_limint_type:type,
    });


  }




  onChangeText(text){


    var new_amount = '';


    if (!text || text.length == 0 || text.length == 1) {

      new_amount = '$';

    }else {

       new_amount = text;

    }


   this.setState({
      intput_amount:new_amount,
    });

  }



  clickLimitDone(){


    if (this.state.selected_limint_type == 0) {

      //无限制
      this.coverLayer.hide();
      this.setCardFriendLimit('-1');



    }else {

      // 有限制金额 

      //判断金额是否正确

      if (this.state.intput_amount) {

        var str_amount = this.state.intput_amount;

        var amount = str_amount.substr(1,str_amount.length - 1);

        if (!StringUtils.isNumber(amount)) {

          toastShort('Please enter the correct amount！');
        }else{

           this.coverLayer.hide();
           this.setCardFriendLimit(amount);
        }

      }

    }

  }






  clickAmount(amount){

    this.setState({
      selected_amount_type:amount,
      intput_amount:'$' + amount + '.00',
    });



  }


  setCardFriendLimit(limit){


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
    '<v:Header />'+
    '<v:Body><n0:setCardFriendLimit id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<transLimit i:type="d:string">'+ limit +'</transLimit>'+
    '<id i:type="d:string">'+this.state.card_friend.id +'</id>'+
    '</n0:setCardFriendLimit></v:Body></v:Envelope>';

    var temporary = this;
    Loading.show();
    WebserviceUtil.getQueryDataResponse('voucher','setCardFriendLimitResponse',data, function(json) {

        Loading.hidden();
        if (json && json.success == 1) {

          var  card_friend = temporary.state.card_friend;

          card_friend.trans_limit = limit;

          temporary.setState({
            card_friend:card_friend,
          });



        }else {

          toastShort('Setting Failed!');
        }


    });      


  }





render() {

    const { navigation } = this.props;

    var name = '';
    var phone = '';

    var trans_linmit = -1;

    if (this.state.card_friend) {


      if (this.state.card_friend.first_name) {

        name += this.state.card_friend.first_name;

      }


      if (this.state.card_friend.last_name) {

        if (name == '') {

          name += this.state.card_friend.last_name;

        }else {

          name += (' ' + this.state.card_friend.last_name);
        }
        
      }

      phone = this.state.card_friend.mobile;


      try{

        trans_linmit = parseFloat(this.state.card_friend.trans_limit);

      }catch(e){


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


                  <View style = {styles.card_friend_info}>


                      <View style = {styles.view_name_delete}>

                        <Text style = {styles.text_name}>{name}</Text>



                        <TouchableOpacity 
                          activeOpacity = {0.8 }
                          onPress={this.clickDeleteUser.bind(this)}> 


                           <Image 
                            style = {{width:32,height:32}} 
                            resizeMode = 'contain' 
                            source={require('../../../../images/yuan_shang.png')}/>  





                        </TouchableOpacity>   

   
                      </View>


                      <Text style = {styles.text_phone}>{phone}</Text>


                  </View>



                  <View  style = {styles.view_line}/>


                  <View style = {styles.card_friend_info}>


                      <Text style = {styles.text_limit}>Transaction Limit</Text>




                      <TouchableOpacity 
                          style = {{width:'100%'}}
                          activeOpacity = {0.8 }
                          onPress={this.clickTransactionLimit.bind(this)}> 


                           <View style = {[styles.view_name_delete,{marginTop:16}]}>

                                <Text>{ trans_linmit ==  -1 ? 'no limit per transaction' : '$' + trans_linmit + ' limit per transaction'}</Text>

                               <Image 
                                  style = {{width:8,height:13}} 
                                  resizeMode = 'contain' 
                                  source={require('../../../../images/you.png')}/>    

                           </View>




                     </TouchableOpacity>     


                     


                  </View>



                   <View  style = {styles.view_line}/>



                   <Text style = {[styles.text_limit,{marginTop:16,marginLeft:24,marginBottom:16}]}>Transactions By User</Text>



                   {this._transactionsItemsView()}



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
  view_name_delete:{
    width:'100%',
    alignItems: 'center',
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  text_name:{
    fontSize:24,
    fontWeight:'bold',
    color:'#145A7C',
  },
  card_friend_info:{
    padding:24,
    width:'100%',
  },
  text_phone:{
    marginTop:8,
    fontSize:16,
    color:'#333333',
  },
  view_line:{
    backgroundColor:'#e0e0e0',
    height:1,
    width:'100%',
  },
  text_limit:{
    fontSize:16,
    color:'#333333',
    fontWeight:'bold',
  },
  view_tran_item_date:{
      paddingLeft:24,
      backgroundColor:'#f2f2f2f2',
      width:'100%',
      height:24,
      justifyContent: 'center',
  },
  text_tran_item_date:{

    fontSize:13,
    fontWeight:'bold',
    color:'#333333',

  },
  text_tran_item_name :{
    fontSize:14,
    fontWeight:'bold',
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
  text_popup_title:{
    width:'100%',
    color:'#145A7C',
    fontSize:18,
    textAlign :'center',
    fontWeight: 'bold',
  },
  view_limit_item:{
    marginTop:32,
     width:'100%',
    flexDirection: 'row'
  },
  text_item_limit:{
    marginLeft:10,
    color:'#000000',
    fontSize:16,
  },
  text_limit_hit:{
    marginLeft:10,
    marginTop:8,
    color:'#828282',
    fontSize:12,
  },
  view_edit:{
    marginTop:22,
    backgroundColor:'#F2F2F2',
    width:'100%',
    height:68,
    borderRadius:16,
  },
   text_input:{
    flex:1,
    color:'#145A7C',
    fontSize:32,
    fontWeight:'bold',
  },
  view_amount_item:{
    width:72,
    height:44,
    backgroundColor:'#F2F2F2',
    borderRadius:16,
    flexDirection: 'row',
    alignItems: 'center',
  },
  text_amount_item:{
    width:'100%',
    color:'#333333',
    fontSize:16,
    fontWeight:'bold',
    textAlign :'center',
  },
  view_amount_list:{
    marginTop:34,
    width:'100%',
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  next_view:{
    marginTop:50,
    marginBottom:69,
    width:'100%',
    backgroundColor:'#FFFFFF'
  },
  next_layout:{
      width:'100%',
      height:44,
      backgroundColor:'#C44729',
      borderRadius: 50,
      justifyContent: 'center',
      alignItems: 'center'
  },
  next_text :{
      fontSize: 14,
      color: '#FFFFFF',
      fontWeight: 'bold',
  },

});



