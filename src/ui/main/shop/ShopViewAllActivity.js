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
  NativeModules
} from 'react-native';

import WebserviceUtil from '../../../uitl/WebserviceUtil';

import { Loading } from '../../../widget/Loading';

import { toastShort } from '../../../uitl/ToastUtils';

import DateUtil from '../../../uitl/DateUtil';

import DeviceStorage from '../../../uitl/DeviceStorage';

import IparInput from '../../../widget/IparInput';

import CoverLayer from '../../../widget/xpop/CoverLayer';

import CheckBox from 'react-native-check-box'

import StringUtils from '../../../uitl/StringUtils';


import TitleBar from '../../../widget/TitleBar';


export default class ShopViewAllActivity extends Component {


   constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       userBean:undefined,
       view_all_type:0, // 0 : recently viewed  1: New Products
       data:[],
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


    var view_all_type = 0;

    if (this.props && this.props.view_all_type != undefined) {
      this.setState({
        view_all_type:this.props.view_all_type,
      });

      view_all_type = this.props.view_all_type;
    }else {
      if (this.props.route.params) {
        this.setState({
          view_all_type:this.props.route.params.view_all_type,
        });
  
        view_all_type = this.props.route.params.view_all_type;
  
      }
  
    }
    

    DeviceStorage.get('UserBean').then((user_bean) => {

      this.setState({
          userBean: user_bean,
      });


      if (view_all_type == 0) {
        this.getRecentViewedProduct(user_bean);
      }else if (view_all_type == 1){
        this.getNewFeaturedProducts(user_bean);
      }


    });
     
  }


  getRecentViewedProduct(userBean){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body>'+
    '<n0:getRecentViewedProduct id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<isOnline i:type="d:string">1</isOnline>'+
    '<limit i:type="d:string">50</limit>'+
    '<clientId i:type="d:string">'+ userBean.id +'</clientId>'+
    '</n0:getRecentViewedProduct></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('product','getRecentViewedProductResponse',data, function(json) {

        if (json && json.success == 1) {
           temporary.setState({
              data:json.data, 
           });
           
        }

    });    

  }

  getNewFeaturedProducts(userBean){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body>'+
    '<n0:getNewFeaturedProducts id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<companyId i:type="d:string">'+ this.state.head_company_id +'</companyId>'+
    '<isFeatured i:type="d:string">0</isFeatured>'+
    '<isOnline i:type="d:string">1</isOnline>'+
    '<isNew i:type="d:string">1</isNew>'+
    '<limit i:type="d:string">50</limit>'+
    '<clientId i:type="d:string">'+ this.state.userBean.id +'</clientId>'+
    '</n0:getNewFeaturedProducts></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('product','getNewFeaturedProductsResponse',data, function(json) {

        if (json && json.success == 1) {
           temporary.setState({
              data:json.data, 
           });
           
        }

    });    

  }

   _renderItem = (item) =>{


    var picture = item.item.picture;
    var image_url = '';
    if (picture) {
      image_url = picture.slice(1,picture.length);
    }


    return(

      <TouchableOpacity
          style = {[{width:'100%',padding:24},{paddingTop:item.index == 0 ? 24 : 0}]}
          onPress={this.clickItem.bind(this,item)}>

          <View style = {{width:'100%'}}>

          <View style = {styles.view_item}>

              <View style = {styles.view_image_card}>


                 <Image 
                    style={{flex:1,borderRadius:16}}
                    source={{uri: WebserviceUtil.getImageHostUrl() + image_url}}
                    resizeMode="cover" />



                 <View style = {styles.view_item_like}>


                     <TouchableOpacity
                        onPress={this.clickLikeProduct.bind(this,item)}>

                        <Image
                          style={{width:15,height:15}}
                          source={item.item.isLike ? require('../../../../images/xing_hong_1223.png') : require('../../../../images/bai_xing.png')}
                          resizeMode = 'contain' />
                    </TouchableOpacity>      
                 </View>

              </View>


              <View style = {{flex:1,paddingLeft:20,paddingTop:8}}>


                  <Text style = {styles.text_item_name}>{item.item.alias}</Text>


                  <View style = {styles.view_item_price}>


                      <Text style = {styles.text_item_price}>{'$' + item.item.sell_price}</Text>


                  </View>

              </View>
        
          </View>

          <View style = {styles.view_line} />

        </View>

      </TouchableOpacity>    

      
    );

   }


   clickItem(item){

      if (this.props.isNative) {
        NativeModules.NativeBridge.openNativeVc('RNBridgeViewController',{pageName:'ShopProductDetailActivity',property:{
          'product_id':item.item.id
        }});
        return;
      }
      const { navigation } = this.props;
   
      if (navigation) {
        navigation.navigate('ShopProductDetailActivity',{
          'product_id':item.item.id
        });
      }

   }


  clickLikeProduct(item){

    if(item.item.isLike){

      this.deleteLikeProduct(item.item.id);
    }else {

      this.saveLikeProduct(item.item.id);
    }

  }

  deleteLikeProduct(productId){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body>'+
    '<n0:deleteLikeProduct id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<productId i:type="d:string">'+ productId +'</productId>'+
    '<clientId i:type="d:string">'+ this.state.userBean.id +'</clientId><'+
    '/n0:deleteLikeProduct></v:Body></v:Envelope>';

    var temporary = this;
    Loading.show();
    WebserviceUtil.getQueryDataResponse('product','deleteLikeProductResponse',data, function(json) {

        Loading.hidden();
        if (json && json.success == 1) {

          if (temporary.state.view_all_type == 0) {
              temporary.getRecentViewedProduct(temporary.state.userBean);
          }else if (temporary.state.view_all_type == 1) {
            temporary.getNewFeaturedProducts(temporary.state.userBean);
          }

          
        }

    });      
  } 

  saveLikeProduct(productId){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body>'+
    '<n0:saveLikeProduct id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<productId i:type="d:string">'+ productId +'</productId>'+
    '<clientId i:type="d:string">'+ this.state.userBean.id + '</clientId>'+
    '</n0:saveLikeProduct></v:Body></v:Envelope>';

    var temporary = this;
    Loading.show();
    WebserviceUtil.getQueryDataResponse('product','saveLikeProductResponse',data, function(json) {

        Loading.hidden();
        if (json && json.success == 1) {       
            if (temporary.state.view_all_type == 0) {
              temporary.getRecentViewedProduct(temporary.state.userBean);
          }else if (temporary.state.view_all_type == 1) {
            temporary.getNewFeaturedProducts(temporary.state.userBean);
          }
        }

    });      
  }




  render() {

    const { navigation } = this.props;

    return (

        <View style = {styles.bg}>

          <StatusBar barStyle="light-content" backgroundColor='#FFFFFF' translucent={false} />


           <SafeAreaView style = {styles.afearea} >


               <TitleBar
                  title = {this.state.view_all_type == 0 ? 'Recently Viewed' : 'New Products'} 
                  navigation={navigation}
                  hideLeftArrow = {true}
                  hideRightArrow = {false}
                  extraData={this.state}/>



                <View style = {[styles.bg]}>



                   <View style = {styles.view_search}>


                      <TextInput
                        style={styles.textInput}
                        placeholder="Search"/>


                  </View>



                   <FlatList
                      style = {{flex:1}}
                      ref = {(flatList) => this._flatList = flatList}
                      renderItem = {this._renderItem}
                      onEndReachedThreshold={0}
                      keyExtractor={(item, index) => index.toString()}
                      data={this.state.data}/>  
 
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
    backgroundColor:'#FFFFFF',
  },
  afearea:{
    flex:1,
    backgroundColor:'#145A7C'
  },
  afearea_foot:{
    flex:0,
    backgroundColor:'#FFFFFF'
  },
  view_item : {
    width:'100%',
    flexDirection: 'row',
  },
  view_image_card:{
    flex:1,
    backgroundColor:'#F2F2F2',
    borderRadius:16,
    width:'100%',
    height:120,
  },
  text_item_name:{
    fontWeight: 'bold',
    fontSize:14,
    color:'#333333',
  },
  view_item_price : {
    marginTop:16,
    width:'100%',
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  text_item_price:{
    marginTop:8,
    fontSize:16,
    color:'#333333',
  },
  view_product_num:{
    marginTop:8,
    flexDirection: 'row',
  },
  text_num:{
    width:30,
    marginTop:4,
    color:'#333',
    fontSize: 14,
    fontWeight: 'bold',
    textAlign:'center',
  },
  view_line : {
    marginTop : 16,
    backgroundColor:'#E0e0e0',
    width:'100%',
    height:1,
  },
  view_list_foot:{
    width:'100%',
    padding:16,
  },
  view_foot_item:{
    width:'100%',
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  text_total:{
    color:'#333',
    fontSize: 14,
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
    marginTop:16
  },
  view_item : {
    width:'100%',
    flexDirection: 'row',
  },
  view_image_card:{
    flex:1,
    backgroundColor:'#F2F2F2',
    borderRadius:16,
    width:'100%',
    height:120,
    flexDirection:'row-reverse',
  },
  text_item_name:{
    fontWeight: 'bold',
    fontSize:14,
    color:'#333333',
  },
  view_item_price : {
    marginTop:16,
    width:'100%',
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  text_item_price:{
    marginTop:8,
    fontSize:16,
    color:'#333333',
  },
  view_product_num:{
    marginTop:8,
    flexDirection: 'row',
  },
  view_item_like:{
    margin:8,
    borderRadius:50,
    width:25,
    height:25,
    backgroundColor:'#FFFFFF',
    position:'absolute',
    justifyContent: 'center',
    alignItems: 'center',
  },
  view_search:{
    paddingTop:8,
    paddingLeft:16,
    paddingRight:16,
    paddingBottom:8,
    borderRadius: 50,
    margin:24,
    height:40,
    borderWidth:0.5,
    borderColor:'#CCC'
  },
  textInput:{
    flex:1,
  },
});