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

let {width, height} = Dimensions.get('window');

export default class TierPrivilegesActivity extends Component {

  constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       userBean:undefined,
       silver_discounts:[],
       gold_discounts:[],
       platinum_discounts:[],
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

    // this.getNewCardDiscountsByLevel('2');
    // this.getNewCardDiscountsByLevel('3');
    // this.getNewCardDiscountsByLevel('4');

    this.getCardDiscountDetails('2');
    this.getCardDiscountDetails('3');
    this.getCardDiscountDetails('4');



  }

  getNewCardDiscountsByLevel(cardLevel){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body>'+
    '<n0:getNewCardDiscountsByLevel id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<companyId i:type="d:string">'+ this.state.head_company_id +'</companyId>'+
    '<cardLevel i:type="d:string">'+ cardLevel +'</cardLevel>'+
    '</n0:getNewCardDiscountsByLevel></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('vip-definition','getNewCardDiscountsByLevelResponse',data, function(json) {

        if (json && json.success == 1) {

          if (cardLevel == '2') {
            temporary.setState({
              silver_discounts:json.data, 
           });
        
          }else if (cardLevel == '3') {

            temporary.setState({
              gold_discounts:json.data, 
            });

          }else if (cardLevel == '4') {

            temporary.setState({
              platinum_discounts:json.data, 
            });

          }

        }
           

    });      

  }


  getCardDiscountDetails(cardLevel){


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
    '<v:Header />'+
    '<v:Body><n0:getCardDiscountDetails id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<levelId i:type="d:string">'+ cardLevel +'</levelId>'+
    '</n0:getCardDiscountDetails></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('card-discount-content','getCardDiscountDetailsResponse',data, function(json) {

        if (json && json.success == 1) {
           
          if (cardLevel == '2') {
            temporary.setState({
              silver_discounts:json.data, 
           });
        
          }else if (cardLevel == '3') {

            temporary.setState({
              gold_discounts:json.data, 
            });

          }else if (cardLevel == '4') {
            temporary.setState({
              platinum_discounts:json.data, 
            });

          }

        }

    });      

  }




  _silverView(){

    if (this.state.silver_discounts) {

      var discounts = [];


      if (this.state.silver_discounts.r_discount1 != undefined && this.state.silver_discounts.r_discount1.length > 0) {

          discounts.push(

            <View style = {[styles.view_discount_item,{marginTop:0,marginLeft:16}]}>

                <Text style = {styles.text_discount_item}>·</Text>

                <Text style = {styles.text_discount_item}>{this.state.silver_discounts.r_discount1}</Text>


            </View>

          );
      }


      if (this.state.silver_discounts.r_discount2!= undefined && this.state.silver_discounts.r_discount2.length > 0) {

          discounts.push(

            <View style = {[styles.view_discount_item,{marginTop:0,marginLeft:16}]}>

                <Text style = {styles.text_discount_item}>·</Text>

                <Text style = {styles.text_discount_item}>{this.state.silver_discounts.r_discount2}</Text>


            </View>

          );
      }


      if (this.state.silver_discounts.r_discount3 != undefined && this.state.silver_discounts.r_discount3.length > 0) {

          discounts.push(

            <View style = {[styles.view_discount_item,{marginTop:0,marginLeft:16}]}>

                <Text style = {styles.text_discount_item}>·</Text>

                <Text style = {styles.text_discount_item}>{this.state.silver_discounts.r_discount3}</Text>


            </View>

          );
      }


      return discounts;


    }else {

        return (<View />);

    }


  }


  _goldView(){

    if (this.state.gold_discounts ) {


      var discounts = [];

    

      if (this.state.gold_discounts.r_discount1 != undefined && this.state.gold_discounts.r_discount1.length > 0) {

          discounts.push(

            <View style = {[styles.view_discount_item,{marginTop:0,marginLeft:16}]}>

                <Text style = {styles.text_discount_item}>·</Text>

                <Text style = {styles.text_discount_item}>{this.state.gold_discounts.r_discount1}</Text>


            </View>

          );
      }


      if (this.state.gold_discounts.r_discount2!= undefined && this.state.gold_discounts.r_discount2.length > 0) {

          discounts.push(

            <View style = {[styles.view_discount_item,{marginTop:0,marginLeft:16}]}>

                <Text style = {styles.text_discount_item}>·</Text>

                <Text style = {styles.text_discount_item}>{this.state.gold_discounts.r_discount2}</Text>


            </View>

          );
      }


      if (this.state.gold_discounts.r_discount3 != undefined && this.state.gold_discounts.r_discount3.length > 0) {

          discounts.push(

            <View style = {[styles.view_discount_item,{marginTop:0,marginLeft:16}]}>

                <Text style = {styles.text_discount_item}>·</Text>

                <Text style = {styles.text_discount_item}>{this.state.gold_discounts.r_discount3}</Text>


            </View>

          );
      }




      return discounts;



    }else {


        return (<View />);


    }


  }


  _platinumView(){

    if (this.state.platinum_discounts ) {


      var discounts = [];

      
       if (this.state.platinum_discounts.r_discount1 != undefined && this.state.platinum_discounts.r_discount1.length > 0) {

          discounts.push(

            <View style = {[styles.view_discount_item,{marginTop:0,marginLeft:16}]}>

                <Text style = {styles.text_discount_item}>·</Text>

                <Text style = {styles.text_discount_item}>{this.state.platinum_discounts.r_discount1}</Text>


            </View>

          );
      }


      if (this.state.platinum_discounts.r_discount2!= undefined && this.state.platinum_discounts.r_discount2.length > 0) {

          discounts.push(

            <View style = {[styles.view_discount_item,{marginTop:0,marginLeft:16}]}>

                <Text style = {styles.text_discount_item}>·</Text>

                <Text style = {styles.text_discount_item}>{this.state.platinum_discounts.r_discount2}</Text>


            </View>

          );
      }


      if (this.state.platinum_discounts.r_discount3 != undefined && this.state.platinum_discounts.r_discount3.length > 0) {

          discounts.push(

            <View style = {[styles.view_discount_item,{marginTop:0,marginLeft:16}]}>

                <Text style = {styles.text_discount_item}>·</Text>

                <Text style = {styles.text_discount_item}>{this.state.platinum_discounts.r_discount3}</Text>


            </View>

          );
      }  



      return discounts;



    }else {


        return (<View />);


    }


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




   render() {

     const { navigation } = this.props;

     return(

       <View style = {styles.bg}>

          <StatusBar barStyle="light-content" backgroundColor='#FFFFFF' translucent={false} />

          <SafeAreaView style = {styles.afearea} >

              <TitleBar
                title = {'Tier Privileges'} 
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



                    <View style = {styles.view_leve}>

                        <Text style = {styles.text_tiers_name}>Basic Tier</Text>

                        <Text style = {styles.text_discount_item}>Begin your journey by making your purchases and top up through this card, you'll be able to earn points and progress to another tier!</Text>



                         <Card  cornerRadius={16} opacity={0.1} elevation={4}  style = {{width:width - 64,margin:8}} >

                            
                            <View style = {{height:120,borderRadius:16}}>


                              <Image 
                                  style = {{width:'100%',height:120,borderRadius:16}} 
                                  source={require('../../../../images/car_lv_4.png')}/>     


                              <View style = {[styles.view_user_info]}>


                                  <Text style = {styles.text_leve_name}>Basic</Text>

                                  <Text style = {styles.text_leve_amount}>$0</Text>

                              </View>    

                            </View>

                        </Card>


                         
                    </View>


                    

                   


                    <View style = {styles.view_line}/>



                    <View style = {styles.view_leve}>

                        <Text style = {styles.text_tiers_name}>Silver Tier</Text>

                        <Text style = {styles.text_discount_item}>Spend or Top up an accumulated amount of $500 to attained this member tier</Text>


                         <Card  cornerRadius={16} opacity={0.1} elevation={4}  style = {{width:width - 64,margin:8,marginTop:16}} >

                             <View style = {{width:'100%',paddingBottom:16}}>

                                  <View style = {{height:120,borderRadius:16}}>

                                    <Image 
                                        style = {{width:'100%',height:120,borderRadius:16}} 
                                        source={require('../../../../images/car_lv_1.png')}/>     


                                    <View style = {[styles.view_user_info]}>


                                        <Text style = {styles.text_leve_name}>Silver</Text>

                                        <Text style = {styles.text_leve_amount}>$500</Text>

                                    </View>    

                                  </View>


                                  <Text style = {[styles.text_tiers_name,{padding:16}]}>Your Privileges</Text>


                                  {this._silverView()}




                             </View> 

                            
                         </Card>
    
                    </View>


                    <View style = {styles.view_line}/>



                    <View style = {styles.view_leve}>

                        <Text style = {styles.text_tiers_name}>Gold Tier</Text>

                        <Text style = {styles.text_discount_item}>Spend or Top up an accumulated amount of $1000 to attained this member tier</Text>


                         <Card  cornerRadius={16} opacity={0.1} elevation={4}  style = {{width:width - 64,margin:8,marginTop:16}} >

                             <View style = {{width:'100%',paddingBottom:16}}>

                                  <View style = {{height:120,borderRadius:16}}>

                                    <Image 
                                        style = {{width:'100%',height:120,borderRadius:16}} 
                                        source={require('../../../../images/car_lv_3.png')}/>     


                                    <View style = {[styles.view_user_info]}>


                                        <Text style = {styles.text_leve_name}>Gold</Text>

                                        <Text style = {styles.text_leve_amount}>$1000</Text>

                                    </View>    

                                  </View>


                                  <Text style = {[styles.text_tiers_name,{padding:16}]}>Your Privileges</Text>


                                  {this._goldView()}


                             </View> 

                            
                         </Card>
    
                    </View>


                    <View style = {styles.view_line}/>


                 
                    <View style = {styles.view_leve}>

                        <Text style = {styles.text_tiers_name}>Platinum Tier</Text>

                        <Text style = {styles.text_discount_item}>Spend or Top up an accumulated amount of $2000 to attained this member tier</Text>


                         <Card  cornerRadius={16} opacity={0.1} elevation={4}  style = {{width:width - 64,margin:8,marginTop:16}} >

                             <View style = {{width:'100%',paddingBottom:16}}>

                                  <View style = {{height:120,borderRadius:16}}>

                                    <Image 
                                        style = {{width:'100%',height:120,borderRadius:16}} 
                                        source={require('../../../../images/car_lv_2.png')}/>     


                                    <View style = {[styles.view_user_info]}>


                                        <Text style = {styles.text_leve_name}>Platinum</Text>

                                        <Text style = {styles.text_leve_amount}>$2000</Text>

                                    </View>    

                                  </View>


                                  <Text style = {[styles.text_tiers_name,{padding:16}]}>Your Privileges</Text>


                                  {this._platinumView()}


                             </View> 

                            
                         </Card>
    
                    </View>


                    <View style = {styles.view_line}/>



                  <View style = {styles.view_tiers}>

                     <TouchableOpacity 
                        activeOpacity = {0.8 }
                        onPress={this.clickTermsAndConditions.bind(this)}> 


                        <View style = {styles.view_name_volue}>

                          <Text style = {styles.text_tiers_name}>Terms and Conditions</Text>

                           
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
    marginTop:5,
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
  view_leve:{
    padding:24
  },
  text_leve_name:{
    color:'#333333',
    fontSize:24,
  },
  text_leve_amount:{
    color:'#333333',
    fontSize:36,
    fontWeight:'bold'
  }

});



