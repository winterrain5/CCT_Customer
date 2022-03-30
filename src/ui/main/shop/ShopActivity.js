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
  NativeModules,
  RefreshControl
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

import Swiper from 'react-native-swiper';

let nativeBridge = NativeModules.NativeBridge;

export default class ShopActivity extends Component {


   constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       userBean:undefined,
       services:undefined,
       products_cart_count:0,
       page:0,
       shop_banner:undefined,
       recently_data:undefined,
       new_product_data:undefined,
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


    this.cartCount();

    DeviceStorage.get('UserBean').then((user_bean) => {

      this.setState({
          userBean: user_bean,
      });

      this.getNewFeaturedProducts(user_bean);

      this.getRecentViewedProduc(user_bean);

      this.getNewFeaturedNewProducts(user_bean);

    });

     
  }

  cartCount(){

     DeviceStorage.get('shop_cart').then((cart_json) => {

        var carts = [];

        if (cart_json) {

            carts = JSON.parse(cart_json,'utf-8');
        }
        
        this.setState({
          products_cart_count:carts.length,
        });


      });

  }

  // 下啦刷新
  _onRefresh(){


      this.setState({
          isRefreshing:true,
      });


    this.getNewFeaturedProducts(this.state.userBean);

    this.getRecentViewedProduc(this.state.userBean);

    this.getNewFeaturedNewProducts(this.state.userBean);


  }




   //注册通知
  componentDidMount(){

      var temporary = this;

      this.emit =  DeviceEventEmitter.addListener('shop_cart_up',(params)=>{
            //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI
           temporary.cartCount();
       });


      this.emit1 =  DeviceEventEmitter.addListener('like_products_removed',(params)=>{
            //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI

          
          temporary.getNewFeaturedProducts(temporary.state.userBean);

          temporary.getRecentViewedProduc(temporary.state.userBean);

          temporary.getNewFeaturedNewProducts(temporary.state.userBean);


       });




  }

  componentWillUnmount(){

    this.emit.remove();
    this.emit1.remove();
  
  }





  getNewFeaturedProducts(userBean){


     if (!userBean) {
      return
    }
    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getNewFeaturedProducts id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<companyId i:type="d:string">'+ this.state.head_company_id +'</companyId>'+
    '<isFeatured i:type="d:string">1</isFeatured>'+
    '<isOnline i:type="d:string">1</isOnline>'+
    '<isNew i:type="d:string">0</isNew>'+
    '<limit i:type="d:string">4</limit>'+
    '<clientId i:type="d:string">'+ userBean.id +'</clientId>'+
    '</n0:getNewFeaturedProducts></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('product','getNewFeaturedProductsResponse',data, function(json) {

        if (json && json.success == 1) {
           temporary.setState({
              shop_banner:json.data, 
           });
        }

        temporary.setState({
          isRefreshing:false,
        });

    });      


  }


   getRecentViewedProduc(userBean){

     if (!userBean) {
      return
    }
    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getRecentViewedProduct id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<isOnline i:type="d:string">1</isOnline>'+
    '<limit i:type="d:string">4</limit>'+
    '<clientId i:type="d:string">'+ userBean.id +'</clientId>'+
    '</n0:getRecentViewedProduct></v:Body></v:Envelope>';
    var temporary = this;
    WebserviceUtil.getQueryDataResponse('product','getRecentViewedProductResponse',data, function(json) {

        if (json && json.success == 1 && json.data) {
            
            var products = [];
            var product_chien = [];

            for (var i = 0; i < json.data.length; i++) {
             
                if (i % 2 == 0) {

                  if (product_chien.length > 0) {
                      products.push(product_chien);
                  }
                  product_chien = [];

                }

                product_chien.push(json.data[i]);

            }

            if (product_chien.length > 0) {
              products.push(product_chien);
            }

            temporary.setState({
              recently_data:products,
            });

            
        }else {
          temporary.setState({
              recently_data:[],
            });
        }

    });      


  }


  getNewFeaturedNewProducts(userBean){

     if (!userBean) {
      return
    }

   var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getNewFeaturedProducts id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<companyId i:type="d:string">'+ this.state.head_company_id +'</companyId>'+
    '<isFeatured i:type="d:string">0</isFeatured>'+
    '<isOnline i:type="d:string">1</isOnline>'+
    '<isNew i:type="d:string">1</isNew>'+
    '<limit i:type="d:string">4</limit>'+
    '<clientId i:type="d:string">'+ userBean.id +'</clientId>'+
    '</n0:getNewFeaturedProducts></v:Body></v:Envelope>';


    var temporary = this;
    WebserviceUtil.getQueryDataResponse('product','getNewFeaturedProductsResponse',data, function(json) {


        if (json && json.success == 1 && json.data) {
            
            var products = [];
            var product_chien = [];

            for (var i = 0; i < json.data.length; i++) {
             
                if (i % 2 == 0) {

                  if (product_chien.length > 0) {
                      products.push(product_chien);
                  }
                  product_chien = [];

                }

                product_chien.push(json.data[i]);

            }

            if (product_chien.length > 0) {
              products.push(product_chien);
            }

            temporary.setState({
              new_product_data:products,
            });

            
        }else {
          temporary.setState({
              new_product_data:[],
            });
        }

    });      

  }




  back(){
    if (this.props.navigation) {
      this.props.navigation.goBack();
    }else {
      nativeBridge.goBack();
    }
     
  }


  clickLike(){

    if (this.props.isNative) {
      NativeModules.NativeBridge.openNativeVc("RNBridgeViewController",{pageName:"ShopLikeActivity"});
    }else {
      const { navigation } = this.props;
   
      if (navigation) {
        navigation.navigate('ShopLikeActivity');
      }
    }
    

  }

  clickCar(){
    if (this.props.isNative) {
      NativeModules.NativeBridge.openNativeVc("RNBridgeViewController",{pageName:"ProductCartActivity",property:{'product_detail':undefined,'buy_now':0}});
    }else {
      const { navigation } = this.props;

      if (navigation) {
        navigation.navigate('ProductCartActivity',{
          'product_detail':undefined,
          'buy_now':0,
        });
      }
    }
  }

  clickCCT(){
    if (this.props.isNative) {
      NativeModules.NativeBridge.openNativeVc("RNBridgeViewController",{pageName:"CCTShopActivity",property:{'isCctMap':0}});
    }else {
      const { navigation } = this.props;
   
      if (navigation) {
        navigation.navigate('CCTShopActivity',{
          'isCctMap':0
        });
      }
    }
   
  }

  clickMap(){

    if (this.props.isNative) {
      NativeModules.NativeBridge.openNativeVc("RNBridgeViewController",{pageName:"CCTShopActivity",property:{'isCctMap':2}});
      return;
    }

    const { navigation } = this.props;
   
    if (navigation) {
      navigation.navigate('CCTShopActivity',{
        'isCctMap':2
      });
    }

  }


  shopBanner(){


  
    if  ( this.state.shop_banner) {

       var pages = [];


       for (var i = 0; i < this.state.shop_banner.length; i++) {
        

          var picture = this.state.shop_banner[i].picture;

          var image_url = picture.slice(1,picture.length);

          pages.push(

             <TouchableOpacity
                key = {i + ''}
                style = {styles.img_banner}  
                onPress={this.clickProduct.bind(this,this.state.shop_banner[i])}>

                <Image 
                  
                  style={styles.img_banner}
                  source={{uri: WebserviceUtil.getImageHostUrl() + image_url}}
                  resizeMode="cover" />

             </TouchableOpacity>       

             
          );

       }





      return (

          <Swiper
            loop={true}  
            height={257}
            index = {this.state.page}
            showsPagination={true} 
            paginationStyle={{bottom: 24}}
            autoplay={true} 
            horizontal={true}
            dot={<View style = {[styles.indicator_item,{backgroundColor:'#BDBDBD'}]}></View>}
            activeDot={<View style = {[styles.indicator_item,{backgroundColor:'#145A7C'}]}></View>}
            >

            {pages}

          </Swiper>   

        );
    }else {

      return (<View />);

    }

  }


  recentlyViewed(){


    if (this.state.recently_data && this.state.recently_data.length > 0) {

       var pages = [];

       for (var i = 0; i < this.state.recently_data.length; i++) {


          if (this.state.recently_data[i].length >= 2) {

            var xing1 = [];
            var xing2 = [];

            var avg_rating_1 = parseInt(this.state.recently_data[i][0].avg_rating);
            var avg_rating_2 = parseInt(this.state.recently_data[i][1].avg_rating);


            var picture1 = this.state.recently_data[i][0].picture;
            var image_url1 = '';
            if (picture1) {
              image_url1 = picture1.slice(1,picture1.length);
            }


            var picture2 = this.state.recently_data[i][1].picture;
            var image_url2 = '';
            if (picture2) {
              image_url2 = picture2.slice(1,picture2.length);
            }



            for (var j = 0; j < 5; j++) {

                if (j + 1  <=  avg_rating_1) {

                  xing1.push(
                     <Image
                        key = {j + ''}
                        style={{width:15,height:15}}
                        source={require('../../../../images/xingxing.png')}
                        resizeMode = 'contain' />
                  );

                }else {

                  xing1.push(
                     <Image
                        key = {j + ''}
                        style={{width:15,height:15}}
                        source={require('../../../../images/hui_xingxing.png')}
                        resizeMode = 'contain' />
                  );

                }


                if (j + 1  <=  avg_rating_2) {

                  xing2.push(
                     <Image
                        key = {j + ''}
                        style={{width:15,height:15}}
                        source={require('../../../../images/xingxing.png')}
                        resizeMode = 'contain' />
                  );

                }else {

                  xing2.push(
                     <Image
                        key = {j + ''}
                        style={{width:15,height:15}}
                        source={require('../../../../images/hui_xingxing.png')}
                        resizeMode = 'contain' />
                  );

                }
            }


            pages.push(

              <View  key = {i + ''}  style = {styles.view_product}>


                 <TouchableOpacity
                    style = {styles.view_product_item}  
                    onPress={this.clickProduct.bind(this,this.state.recently_data[i][0])}>


                    <View style = {[styles.view_product_item,{marginRight:4}]}>

                      <View style = {{flex:1,height:120,flexDirection:'row-reverse'}}>

                          <View style = {styles.view_image_card}>

                               <Image 
                                style={{flex:1,borderRadius:16}}
                                source={{uri: WebserviceUtil.getImageHostUrl() + image_url1}}
                                resizeMode="cover" />


                          </View>

                       


                          <TouchableOpacity
                            style = {styles.view_item_like}
                            onPress={this.clickLikeProduct.bind(this,this.state.recently_data[i][0])}>


                            <View style = {styles.view_item_like}>

                               <Image
                                style={{width:15,height:15}}
                                source={this.state.recently_data[i][0].isLike ? require('../../../../images/xing_hong_1223.png') : require('../../../../images/bai_xing.png')}
                                resizeMode = 'contain' />


                            </View>  

                          </TouchableOpacity> 
                  
                     </View>

                      <Text style = {styles.text_product_name} numberOfLines={1}>{this.state.recently_data[i][0].alias}</Text>

                      <Text style = {styles.text_product_price} numberOfLines={1}>{'$' + this.state.recently_data[i][0].sell_price}</Text>

                      <View style = {styles.view_xing}>

                        {xing1}

                      </View>

                  </View>


                </TouchableOpacity>    



                  
                 <TouchableOpacity
                    style = {styles.view_product_item}  
                    onPress={this.clickProduct.bind(this,this.state.recently_data[i][1])}>


                     <View style = {[styles.view_product_item,{marginLeft:4}]}>

                          <View style = {{flex:1,height:120,flexDirection:'row-reverse'}}>

                              <View style = {styles.view_image_card}>

                                  <Image 
                                    style={{flex:1,borderRadius:16}}
                                    source={{uri: WebserviceUtil.getImageHostUrl() + image_url2}}
                                    resizeMode="cover" />

                              </View>


                            <TouchableOpacity
                                style = {styles.view_item_like}
                                onPress={this.clickLikeProduct.bind(this,this.state.recently_data[i][1])}>  

                                 <View style = {styles.view_item_like}>


                                     <Image
                                        style={{width:15,height:15}}
                                        source={this.state.recently_data[i][1].isLike ? require('../../../../images/xing_hong_1223.png') : require('../../../../images/bai_xing.png')}
                                        resizeMode = 'contain' />

                                </View>

                           </TouchableOpacity>    

                         </View>

                        <Text style = {styles.text_product_name} numberOfLines={1}>{this.state.recently_data[i][1].alias}</Text>

                        <Text style = {styles.text_product_price} numberOfLines={1}>{'$' + this.state.recently_data[i][1].sell_price}</Text>

                        <View style = {styles.view_xing}>

                          {xing2}

                        </View>

                      </View>
          
          
                   </TouchableOpacity>     


                   </View>


               

              );

          }else {

            var xing1 = [];
            var avg_rating_1 = parseInt(this.state.recently_data[i][0].avg_rating);

            var picture1 = this.state.recently_data[i][0].picture;
            var image_url1 = '';
            if (picture1) {
              image_url1 = picture1.slice(1,picture1.length);
            }
      
            for (var j = 0; j < 5; j++) {

                if (j + 1  <=  avg_rating_1) {

                  xing1.push(
                     <Image
                        key = {j + ''}
                        style={{width:15,height:15}}
                        source={require('../../../../images/xingxing.png')}
                        resizeMode = 'contain' />
                  );

                }else {

                  xing1.push(
                     <Image
                        key = {j + ''}
                        style={{width:15,height:15}}
                        source={require('../../../../images/hui_xingxing.png')}
                        resizeMode = 'contain' />
                  );

                }
            }


            pages.push(

              <View  key = {i + ''}  style = {styles.view_product}>


                <TouchableOpacity
                    style = {styles.view_product_item}  
                    onPress={this.clickProduct.bind(this,this.state.new_product_data[i][0])}>


                    <View style = {[styles.view_product_item,{marginRight:4}]}>

                        <View style = {{flex:1,height:120,flexDirection:'row-reverse'}}>

                            <View style = {styles.view_image_card}>

                                 <Image 
                                  style={{flex:1,borderRadius:16}}
                                  source={{uri: WebserviceUtil.getImageHostUrl() + image_url1}}
                                  resizeMode="cover" />


                            </View>

                            <TouchableOpacity
                                style = {styles.view_item_like}
                                onPress={this.clickLikeProduct.bind(this,this.state.recently_data[i][0])}>


                                 <View style = {styles.view_item_like}>

                                       <Image
                                          style={{width:15,height:15}}
                                          source={this.state.recently_data[i][0].isLike ? require('../../../../images/xing_hong_1223.png') : require('../../../../images/bai_xing.png')}
                                          resizeMode = 'contain' />

                                </View>              

                            </TouchableOpacity>     

              
                          

                       </View>

                        <Text style = {styles.text_product_name} numberOfLines={1}>{this.state.recently_data[i][0].alias}</Text>

                        <Text style = {styles.text_product_price} numberOfLines={1} >{'$' + this.state.recently_data[i][0].sell_price}</Text>

                        <View style = {styles.view_xing}>

                          {xing1}

                        </View>

                    </View>

                </TouchableOpacity>    
                  


                <View style = {[styles.view_product_item,{marginLeft:4}]}>

                      

                </View>
      
              </View>


              );

          }


          
       }

      return (

        <View style = {styles.view_recently}>

          <View style = {styles.view_recently_title}>


            <Text style = {styles.text_recently_title}>Recently Viewed</Text>


             <TouchableOpacity
                onPress={this.clickViewAll.bind(this,0)}>

                <Text style = {styles.text_view_all}>View All</Text>

             </TouchableOpacity>    

            

          </View>


          <Swiper
            loop={false}  
            height={257}
            index = {this.state.page}
            showsPagination={true} 
            paginationStyle={{bottom: 24}}
            autoplay={false} 
            horizontal={true}
            dot={<View style = {[styles.indicator_item,{backgroundColor:'#BDBDBD'}]}></View>}
            activeDot={<View style = {[styles.indicator_item,{backgroundColor:'#145A7C'}]}></View>}
            >

            {pages}

          </Swiper>   




        </View>


      );

    }else {

      return (<View/>);

    }
  } 


  clickViewAll(view_all_type){

    if (this.props.isNative) {
      NativeModules.NativeBridge.openNativeVc('RNBridgeViewController',{pageName:'ShopViewAllActivity',property:{
        'view_all_type':view_all_type,
    }});
      return;
    }

    const { navigation } = this.props;

    if (navigation) {
      navigation.navigate('ShopViewAllActivity',{
        'view_all_type':view_all_type,
      });
    }


  }




  clickLikeProduct(item){


    if(item.isLike){

      this.deleteLikeProduct(item.id);
    }else {

      this.saveLikeProduct(item.id);
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
          temporary.getRecentViewedProduc(temporary.state.userBean);
          temporary.getNewFeaturedNewProducts(temporary.state.userBean);
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
          
            temporary.getRecentViewedProduc(temporary.state.userBean);
            temporary.getNewFeaturedNewProducts(temporary.state.userBean);
        }

    });      



  }




  newProducts(){


    if (this.state.new_product_data && this.state.new_product_data.length > 0) {

       var pages = [];

       for (var i = 0; i < this.state.new_product_data.length; i++) {


          if (this.state.new_product_data[i].length >= 2) {

            var xing1 = [];
            var xing2 = [];

            var avg_rating_1 = parseInt(this.state.new_product_data[i][0].avg_rating);
            var avg_rating_2 = parseInt(this.state.new_product_data[i][1].avg_rating);



            var picture1 = this.state.new_product_data[i][0].picture;
            var image_url1 = '';
            if (picture1) {
              image_url1 = picture1.slice(1,picture1.length);
            }


            var picture2 = this.state.new_product_data[i][1].picture;
            var image_url2 = '';
            if (picture2) {
              image_url2 = picture2.slice(1,picture2.length);
            }



            for (var j = 0; j < 5; j++) {

                if (j + 1  <=  avg_rating_1) {

                  xing1.push(
                     <Image
                        key = {j + ''}
                        style={{width:15,height:15}}
                        source={require('../../../../images/xingxing.png')}
                        resizeMode = 'contain' />
                  );

                }else {

                  xing1.push(
                     <Image
                        key = {j + ''}
                        style={{width:15,height:15}}
                        source={require('../../../../images/hui_xingxing.png')}
                        resizeMode = 'contain' />
                  );

                }


                if (j + 1  <=  avg_rating_2) {

                  xing2.push(
                     <Image
                        key = {j + ''}
                        style={{width:15,height:15}}
                        source={require('../../../../images/xingxing.png')}
                        resizeMode = 'contain' />
                  );

                }else {

                  xing2.push(
                     <Image
                        key = {j + ''}
                        style={{width:15,height:15}}
                        source={require('../../../../images/hui_xingxing.png')}
                        resizeMode = 'contain' />
                  );

                }
            }


            pages.push(

              <View  key = {i + ''}  style = {styles.view_product}>


                <TouchableOpacity
                    style = {styles.view_product_item}  
                    onPress={this.clickProduct.bind(this,this.state.new_product_data[i][0])}>

                      <View style = {[styles.view_product_item,{marginRight:4}]}>

                          <View style = {{flex:1,height:120,flexDirection:'row-reverse'}}>

                              <View style = {styles.view_image_card}>

                                   <Image 
                                    style={{flex:1,borderRadius:16}}
                                    source={{uri: WebserviceUtil.getImageHostUrl() + image_url1}}
                                    resizeMode="cover" />

                              </View>


                              <TouchableOpacity
                                  style = {styles.view_item_like}
                                  onPress={this.clickLikeProduct.bind(this,this.state.new_product_data[i][0])}>

                                   <View style = {styles.view_item_like}>

                                     <Image
                                        style={{width:15,height:15}}
                                        source={this.state.new_product_data[i][0].isLike ? require('../../../../images/xing_hong_1223.png') : require('../../../../images/bai_xing.png')}
                                        resizeMode = 'contain' />

                                   </View>            

                               </TouchableOpacity>    


                         </View>

                        <Text style = {styles.text_product_name} numberOfLines={1}>{this.state.new_product_data[i][0].alias}</Text>

                        <Text style = {styles.text_product_price} numberOfLines={1}>{'$' + this.state.new_product_data[i][0].sell_price}</Text>

                        <View style = {styles.view_xing}>

                          {xing1}

                        </View>

                    </View>

                 </TouchableOpacity>


                 <TouchableOpacity
                     style = {styles.view_product_item}  
                    onPress={this.clickProduct.bind(this,this.state.new_product_data[i][1])}>

                    <View style = {[styles.view_product_item,{marginLeft:4}]}>

                          <View style = {{flex:1,height:120,flexDirection:'row-reverse'}}>

                              <View style = {styles.view_image_card}>

                                   <Image 
                                    style={{flex:1,borderRadius:16}}
                                    source={{uri: WebserviceUtil.getImageHostUrl() + image_url2}}
                                    resizeMode="cover" />


                              </View>

                              <TouchableOpacity
                                    style = {styles.view_item_like}
                                    onPress={this.clickLikeProduct.bind(this,this.state.new_product_data[i][1])}>  

                                     <View style = {styles.view_item_like}>

                                       <Image
                                          style={{width:15,height:15}}
                                          source={this.state.new_product_data[i][1].isLike ? require('../../../../images/xing_hong_1223.png') : require('../../../../images/bai_xing.png')}
                                          resizeMode = 'contain' />

                                     </View>


                               </TouchableOpacity>    

                         </View>

                        <Text style = {styles.text_product_name} numberOfLines={1}>{this.state.new_product_data[i][1].alias}</Text>

                        <Text style = {styles.text_product_price} numberOfLines={1}>{'$' + this.state.new_product_data[i][1].sell_price}</Text>

                        <View style = {styles.view_xing}>

                          {xing2}

                        </View>

                    </View>


                 </TouchableOpacity> 
      
              </View>


              );

          }else {

            var xing1 = [];
            var avg_rating_1 = parseInt(this.state.new_product_data[i][0].avg_rating);


            var picture1 = this.state.new_product_data[i][0].picture;
            var image_url1 = '';
            if (picture1) {
              image_url1 = picture1.slice(1,picture1.length);
            }



      
            for (var j = 0; j < 5; j++) {

                if (j + 1  <=  avg_rating_1) {

                  xing1.push(
                     <Image
                        key = {j + ''}
                        style={{width:15,height:15}}
                        source={require('../../../../images/xingxing.png')}
                        resizeMode = 'contain' />
                  );

                }else {

                  xing1.push(
                     <Image
                        key = {j + ''}
                        style={{width:15,height:15}}
                        source={require('../../../../images/hui_xingxing.png')}
                        resizeMode = 'contain' />
                  );

                }
            }


            pages.push(

              <View  key = {i + ''}  style = {styles.view_product}>


                <TouchableOpacity
                    style = {{flex:1}}  
                    onPress={this.clickProduct.bind(this,this.state.new_product_data[i][0])}>



                  <View style = {[styles.view_product_item,{marginRight:4}]}>

                      <View style = {{flex:1,height:120,flexDirection:'row-reverse'}}>

                          <View style = {styles.view_image_card}>

                               <Image 
                                style={{flex:1,borderRadius:16}}
                                source={{uri: WebserviceUtil.getImageHostUrl() + image_url1}}
                                resizeMode="cover" />

                          </View>


                           <TouchableOpacity
                              style = {styles.view_item_like}
                              onPress={this.clickLikeProduct.bind(this,this.state.new_product_data[i][0])}>

                               <View style = {styles.view_item_like}>

                                       <Image
                                          style={{width:15,height:15}}
                                          source={this.state.new_product_data[i][0].isLike ? require('../../../../images/xing_hong_1223.png') : require('../../../../images/bai_xing.png')}
                                          resizeMode = 'contain' />

                               </View>


                          </TouchableOpacity>   

                     </View>

                    <Text style = {styles.text_product_name} numberOfLines={1}>{this.state.new_product_data[i][0].alias}</Text>

                    <Text style = {styles.text_product_price} numberOfLines={1}>{'$' + this.state.new_product_data[i][0].sell_price}</Text>

                    <View style = {styles.view_xing}>

                      {xing1}

                    </View>

                </View>


              </TouchableOpacity> 



                <View style = {[styles.view_product_item,{marginLeft:4}]}>

                      

                </View>
      
              </View>


              );

          }


          
       }

      return (

        <View style = {styles.view_recently}>

          <View style = {styles.view_recently_title}>


            <Text style = {styles.text_recently_title}>New Products</Text>



            <TouchableOpacity
                onPress={this.clickViewAll.bind(this,1)}>

                <Text style = {styles.text_view_all}>View All</Text>

             </TouchableOpacity>    
          

          </View>


          <Swiper
            loop={false}  
            height={257}
            index = {this.state.page}
            showsPagination={true} 
            paginationStyle={{bottom: 24}}
            autoplay={false} 
            horizontal={true}
            dot={<View style = {[styles.indicator_item,{backgroundColor:'#BDBDBD'}]}></View>}
            activeDot={<View style = {[styles.indicator_item,{backgroundColor:'#145A7C'}]}></View>}
            >

            {pages}

          </Swiper>   




        </View>


      );



    }else {


      return (<View/>);

    }

  }  

  clickProduct(product){

    if (this.props.isNative) {
      NativeModules.NativeBridge.openNativeVc('RNBridgeViewController',{pageName:'ShopProductDetailActivity',property:{
        'product_id':product.id
      }});
      return;
    }
    const { navigation } = this.props;
   
    if (navigation) {
      navigation.navigate('ShopProductDetailActivity',{
        'product_id':product.id
      });
    }
  }


  _cartCountView(){


    if (this.state.products_cart_count > 0) {


      return (

           <View style = {{width:20,height:20, position:'absolute'}}>

            <View style = {{width:15,height:15,backgroundColor:'#C44729',borderRadius: 50,marginLeft:8,marginBottom:5,justifyContent: 'center',alignItems: 'center',}}>

                  <Text style = {{color:'#FFFFFF',fontSize:10}}>{this.state.products_cart_count}</Text>
            </View>       
          </View>


      );

    }else {


      return (<View/>);

    }


  }





   render() {


    return(

      <View style = {styles.bg}>

        <StatusBar barStyle="light-content" backgroundColor='#FFFFFF' translucent={false} />


         <SafeAreaView style = {styles.afearea} >


          <View style = {styles.header}>


               <View style = {styles.view_car_like}>

                   <TouchableOpacity  
                      onPress={this.back.bind(this)}>
                      <View style ={styles.rightView} >
                          <Image
                            style={{width:8,height:12}}
                            source={require('../../../../images/left_0909.png')}
                            resizeMode = 'contain' />
                      </View>

                    </TouchableOpacity>


                      <View style ={styles.rightView} />


               </View>


               <Text style = {styles.text_title}>Shop</Text> 


               <View style = {styles.view_car_like}>


                  <TouchableOpacity  
                    onPress={this.clickLike.bind(this)}>
                    <View style ={styles.rightView} >
                        <Image
                          style={{width:20,height:20}}
                          source={require('../../../../images/baise_aixin.png')}
                          resizeMode = 'contain' />
                    </View>

                  </TouchableOpacity>


                  <TouchableOpacity  
                    onPress={this.clickCar.bind(this)}>
                    <View style ={styles.rightView} >
                        <Image
                          style={{width:20,height:20}}
                          source={require('../../../../images/baise_gouwuche.png')}
                          resizeMode = 'contain' />



                        {this._cartCountView()}    


                    

                    </View>
                  </TouchableOpacity>

               </View>

           </View>


           <View style = {styles.bg}>


               <ScrollView 
                  style = {styles.scrollview}
                  showsVerticalScrollIndicator = {false}
                  contentOffset={{x: 0, y: 0}}
                  refreshControl={
                      <RefreshControl
                          refreshing={this.state.isRefreshing}
                          onRefresh={this._onRefresh.bind(this)}
                      />
                  }
                  onScroll={this.changeScroll}>




                  <View style = {styles.view_banner}>


                     {this.shopBanner()}


                  </View>


                 <View style = {styles.view_content}>


                    <View style = {styles.view_cct_mp}>



                          <TouchableOpacity  
                              style = {styles.view_toach}
                              onPress={this.clickCCT.bind(this)}>


                             <View style = {[styles.view_cct,{marginRight:9}]}>

                               <Image
                                style={{width:60,height:60}}
                                source={require('../../../../images/tongming_logo2.png')}
                                resizeMode = 'contain' />


                                <Text style  = {[styles.text_title,{marginTop:8}]}>Chien Chi Tow</Text>

                              </View>



                          </TouchableOpacity>  



                           <TouchableOpacity  
                              style = {styles.view_toach}
                              onPress={this.clickMap.bind(this)}>


                              <View style = {[styles.view_cct,{marginLeft:9,backgroundColor:'#FAF3EB'}]}>


                                <Image
                                  style={{width:60,height:60}}
                                  source={require('../../../../images/facebook_copyxxxhdpi.png')}
                                  resizeMode = 'contain' />


                                  <Text style  = {[styles.text_title,{marginTop:8,color:'#EE8F7B'}]}>Madam Partum</Text>


                              </View>


                          </TouchableOpacity>    
              
                
                    </View>    



                   {this.recentlyViewed()}   



                   {this.newProducts()}



                 </View> 


              </ScrollView>    

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

  header: {
    width: '100%',
    height: 50,
    backgroundColor: '#145A7C',
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  rightView: {
    width: 50,
    height: '100%',
    justifyContent: 'center',
    alignItems: 'center',
  },
  text_title :{
    color:'#FFFFFF',
    fontSize: 16,
    fontWeight: 'bold',
  },
  view_car_like:{
    height:'100%',
    flexDirection: 'row',
  },
  indicator_item:{
    width:24,
    height:4,
    backgroundColor:'#000000',
    borderRadius: 50,
    marginLeft:4,
  },
  view_banner:{
    width:'100%',
    height:257,
    backgroundColor:'#F2F2F2'
  },
  img_banner:{
    width:'100%',
    height:257,
  },
  view_content:{
    width:'100%',
    padding:24,
  },
  view_cct_mp:{
    width:'100%',
    flexDirection: 'row',
    height:115,
  },
  view_toach:{
     flex:1,
     height:115,
  },
  view_cct:{
    borderRadius: 16,
    width:'100%',
    height:115,
    flex:1,
    backgroundColor: '#145A7C',
    justifyContent: 'center',
    alignItems: 'center',
  },
  view_recently:{
    marginTop:24,
    width:'100%',
  },
  view_recently_title:{
    width:'100%',
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  text_recently_title:{
    fontSize:24,
    fontWeight:'bold',
    color:'#145A7C'
  },
  text_view_all:{
    fontSize:14,
    color:'#C44729'
  },
  view_product:{
    marginTop:16,
    width:'100%',
    flexDirection: 'row',
  },
  view_product_item:{
    flex:1,
    height:180
  },
  view_image_card:{
    borderRadius:16,
    width:'100%',
    height:120,
    backgroundColor:'#F2F2F2'
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
  view_xing:{
    marginTop:4,
    width:'100%',
    flexDirection: 'row',
  },
  text_product_name:{
    width:'100%',
    fontSize:14,
    color:'#333',
    fontWeight:'bold',
  },
  text_product_price:{
    marginTop:4,
    width:'100%',
    fontSize:12,
    color:'#828282',
  }
});